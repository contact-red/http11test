use "net"
use "../wire"
use "../runner"

actor HostWithIpv6 is WireCallback
  """
  RFC 3986 §3.2.2 mandates square-bracket syntax for IPv6 literals in
  URIs: `[::1]:port`. Browsers and proxies emit this. Server must
  accept the bracketed form.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-host-ipv6-literal"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: [::1]:80\r\n")
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
          "IPv6 literal Host returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
