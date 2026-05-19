use "net"
use "../wire"
use "../runner"

actor ContentLengthAccuracy is WireCallback
  """
  Covers rfc9110-8.6-09: a sender MUST NOT forward a message with a
  Content-Length header field value that is known to be incorrect. We
  send GET / and verify that the body bytes received after the CRLF CRLF
  header terminator exactly match the Content-Length value the server
  advertised.

  Wrong Content-Length is a major browser-interop hazard: too-large CL
  causes hangs as clients wait for bytes that won't come; too-small CL
  truncates the rendered page and can leak bytes into the next response
  on a kept-alive connection.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-8.6-09"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code < 200) or (code >= 300) then
        _reporter.fail(_test_id,
          "GET / returned " + code.string() + " (target should serve 2xx)")
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    match ResponseParser.content_length(bytes)
    | let cl: USize =>
      match ResponseParser.body_offset(bytes)
      | let body_start: USize =>
        let actual = bytes.size() - body_start
        if actual == cl then
          _reporter.pass(_test_id)
        else
          _reporter.fail(_test_id,
            "Content-Length advertised "
              + cl.string() + " but body was "
              + actual.string() + " bytes")
        end
      | let err: ParseError =>
        _reporter.fail(_test_id, err.describe())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
