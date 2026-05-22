use "net"
use "../wire"
use "../runner"

actor CorsPreflight is WireCallback
  """
  A typical CORS preflight: OPTIONS with `Origin`,
  `Access-Control-Request-Method`, and `Access-Control-Request-Headers`.
  The server may choose to handle preflight (with appropriate Access-
  Control-Allow-* headers) or simply return a 200 / 204 / 404. We just
  verify the server doesn't error.
  """
  let _reporter: Reporter
  let _test_id: String = "fetch-3.2.6-01-cors-preflight"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("OPTIONS / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nOrigin: https://example.com\r\n")
      s.append("Access-Control-Request-Method: POST\r\n")
      s.append("Access-Control-Request-Headers: Content-Type, Authorization\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "CORS preflight returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
