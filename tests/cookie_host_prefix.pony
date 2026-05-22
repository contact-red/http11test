use "net"
use "../wire"
use "../runner"

actor CookieHostPrefix is WireCallback
  """
  RFC 6265bis §4.1.3.2: `__Host-` cookie prefix indicates the cookie
  must satisfy specific security attributes. As a Cookie header value
  from the client, it's opaque — server must accept the literal name.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc6265-4.1.3.2-01-cookie-host-prefix"

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
      s.append("\r\nCookie: __Host-session=abc; __Secure-csrf=xyz\r\n")
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
          "Cookie with __Host-/__Secure- returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
