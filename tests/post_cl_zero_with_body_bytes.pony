use "net"
use "../wire"
use "../runner"

actor PostClZeroWithBodyBytes is WireCallback
  """
  RFC 9110 §9.3.3: post cl zero bytes

  POST with explicit Content-Length: 0 — server reads zero body bytes.
  Body bytes that follow are reinterpreted as the next request. We
  send `garbage` after the CRLFCRLF; on a Connection: close stream, the
  server should respond to the POST and may or may not respond to the
  garbage (depending on whether it parses the garbage as a request).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.3.3-02-post-cl-zero-bytes"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("POST / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nContent-Length: 0\r\n")
      s.append("Connection: close\r\n\r\ngarbage_extra")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    // Just verify first response is a valid HTTP status.
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "POST CL=0 + garbage returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
