use "net"
use "../wire"
use "../runner"

actor ManyHeaders is WireCallback
  """
  Server must accept requests with many small header lines (50). This
  is well below any reasonable per-request limit but bigger than the
  default test stack uses. Real-world requests through CDNs and
  reverse proxies can accumulate dozens of `X-Forwarded-*` / `Via` /
  `X-Request-Id` style headers.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-many-headers"

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
      s.append("\r\n")
      var i: USize = 0
      while i < 50 do
        s.append("X-Header-")
        s.append(i.string())
        s.append(": value")
        s.append(i.string())
        s.append("\r\n")
        i = i + 1
      end
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
        _reporter.fail(_test_id,
          "GET with 50 extra headers returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
