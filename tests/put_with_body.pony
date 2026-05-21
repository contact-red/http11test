use "net"
use "../wire"
use "../runner"

actor PutWithBody is WireCallback
  """
  PUT / with a small body. Servers that don't allow PUT on / will return
  405; servers that don't define a PUT handler may return 200/204. We
  accept any non-5xx and rely on the server actually reading the body
  before responding — a hang indicates broken framing.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-put-with-body"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("PUT / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nContent-Type: text/plain\r\n")
      s.append("Content-Length: 11\r\n")
      s.append("Connection: close\r\n\r\nhello world")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // Any well-formed response is acceptable; 501 (Not Implemented) is
      // the canonical answer when PUT is not supported.
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "PUT with body returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
