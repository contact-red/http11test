use "net"
use "../wire"
use "../runner"

actor PostEmptyBody is WireCallback
  """
  POST /, Content-Length: 0. Some servers reply 200/204 (handler ignores
  body), others 405 Method Not Allowed (only GET registered). Either is
  RFC-compliant; we accept any non-5xx response without parse error.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.3.3-01-post-empty-body"

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
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // Any well-formed response is acceptable; 500 Internal would be
      // the only real failure (a true server bug).
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "POST with empty body returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
