use "net"
use "../wire"
use "../runner"

actor HostWithPort is WireCallback
  """
  Browsers include `:port` in the Host header for any non-default port
  (which is most of dev / Docker / staging). The server must accept and
  match these. Test: send `Host: <host>:<service>` rather than just
  `<host>` and verify 2xx.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.2.2-13-host-with-port"

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
          "Host with port returned " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
