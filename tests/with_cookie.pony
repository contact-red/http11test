use "net"
use "../wire"
use "../runner"

actor WithCookie is WireCallback
  """
  Servers must accept `Cookie:` request headers without crashing,
  whether or not they do anything with the cookies. A bug in cookie
  parsing that returns 4xx for a benign cookie would break every
  authenticated browser session.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc6265-5.4-03-with-cookie"

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
      s.append("\r\nCookie: sessionid=abcdef0123456789; theme=dark\r\n")
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
          "GET with Cookie header returned " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
