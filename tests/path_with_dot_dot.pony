use "net"
use "../wire"
use "../runner"

actor PathWithDotDot is WireCallback
  """
  `..` traversal segments in the URL path. The server SHOULD normalize
  them away before resolution. Whether normalization yields 200 (root)
  or 400/404 (rejected/not-found) depends on the server; we accept any
  non-5xx response.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.3-07-dot-dot-segment"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /../../etc/passwd HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if code < 500 then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "path traversal returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
