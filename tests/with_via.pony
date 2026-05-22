use "net"
use "../wire"
use "../runner"

actor WithVia is WireCallback
  """
  `Via:` is added by HTTP proxies. Any server behind a proxy chain
  sees it. Server must accept (and typically ignore at the origin).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-7.6.3-01-via"

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
      s.append("\r\nVia: 1.1 proxy1.example.com, 1.1 proxy2.example.com\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id, "GET with Via returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
