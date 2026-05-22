use "net"
use "../wire"
use "../runner"

actor ManyCookiesOneHeader is WireCallback
  """
  Real-world cookie headers from established sessions can carry many
  cookies on a single line, semicolon-separated. We send 20 cookies in
  one Cookie header to exercise that growth path.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc6265-5.4-01-many-cookies"

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
      s.append("\r\nCookie: ")
      var i: USize = 0
      while i < 20 do
        if i > 0 then s.append("; ") end
        s.append("ck")
        s.append(i.string())
        s.append("=val")
        s.append(i.string())
        i = i + 1
      end
      s.append("\r\nConnection: close\r\n\r\n")
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
          "many cookies returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
