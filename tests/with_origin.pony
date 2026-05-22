use "net"
use "../wire"
use "../runner"

actor WithOrigin is WireCallback
  """
  `Origin:` is sent by browsers on cross-origin requests (and same-
  origin POST/PUT/DELETE). Required for any CORS-aware server to make
  the right preflight decisions. Even non-CORS servers must accept.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc6454-7-01-origin"

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
      s.append("\r\nOrigin: https://example.com\r\n")
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
        _reporter.fail(_test_id, "GET with Origin returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
