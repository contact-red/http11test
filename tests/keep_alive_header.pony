use "net"
use "../wire"
use "../runner"

actor KeepAliveHeader is WireCallback
  """
  `Keep-Alive: timeout=5, max=100` is an HTTP/1.0-era header for
  persistent connections. RFC 9112 treats it as opaque opaque/deprecated;
  server should ignore but accept.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-keep-alive-header"

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
      s.append("\r\nKeep-Alive: timeout=60, max=100\r\n")
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
          "Keep-Alive header returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
