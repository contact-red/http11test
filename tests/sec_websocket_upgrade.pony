use "net"
use "../wire"
use "../runner"

actor SecWebsocketUpgrade is WireCallback
  """
  WebSocket handshake headers should be accepted (even by servers that
  don't speak WebSocket). The expected outcome is 101 (Switching
  Protocols) for supporting servers, or any non-error status for
  servers that don't.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-sec-websocket-upgrade"

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
      s.append("\r\nUpgrade: websocket\r\n")
      s.append("Connection: Upgrade\r\n")
      s.append("Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n")
      s.append("Sec-WebSocket-Version: 13\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 100) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "WebSocket upgrade attempt returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
