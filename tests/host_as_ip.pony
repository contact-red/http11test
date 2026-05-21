use "net"
use "../wire"
use "../runner"

actor HostAsIp is WireCallback
  """
  `Host: 127.0.0.1:<port>` (bare IPv4 + port) is common in tools like
  curl, telnet, and direct-debug clients. Servers must accept IP
  literals in the Host header just like FQDNs.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-host-as-ip"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: 127.0.0.1:")
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
          "GET with `Host: 127.0.0.1:port` returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
