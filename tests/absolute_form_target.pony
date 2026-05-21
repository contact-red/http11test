use "net"
use "../wire"
use "../runner"

actor AbsoluteFormTarget is WireCallback
  """
  Covers rfc9112-3.2.2-06 (MUST): a server MUST accept the absolute-
  form in request-targets even though most HTTP/1.1 clients only send
  it to proxies. We send `GET http://host:port/ HTTP/1.1` directly
  and expect a normal 2xx.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-3.2.2-06"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET http://")
      s.append(host)
      s.append(":")
      s.append(service)
      s.append("/ HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append(":")
      s.append(service)
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
          "GET with absolute-form request-target returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
