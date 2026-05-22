use "net"
use "../wire"
use "../runner"

actor PathWithDotSegment is WireCallback
  """
  `./` and `.` are valid URI path segments (RFC 3986 §3.3) that mean
  "current directory." Servers may normalize them away or leave them in
  place. We accept any non-5xx.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.3-08-dot-segment"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /./foo/. HTTP/1.1\r\nHost: ")
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
          "GET /./foo/. returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
