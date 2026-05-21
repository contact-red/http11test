use "net"
use "../wire"
use "../runner"

actor UrlWithAtInAuthority is WireCallback
  """
  RFC 9112 §3.2.3: absolute-form `GET http://user@example.com/ HTTP/1.1`.
  The `@` introduces userinfo. RFC says "A sender MUST NOT generate
  the userinfo subcomponent in a request target." Server should
  reject 400.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-3.2.3-01-userinfo-in-target"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET http://user@example.com/ HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 400) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "userinfo in absolute-form target returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
