use "net"
use "../wire"
use "../runner"

actor EchoesConnectionClose is WireCallback
  """
  Covers rfc9112-9.6-04 (SHOULD): the server SHOULD send a "close"
  connection option in its final response on a connection. When a client
  sent `Connection: close`, the server's response should advertise that
  the connection is being closed, so proxies and clients on the path
  know not to expect reuse.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-9.6-04"

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
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code < 200) or (code >= 300) then
        _reporter.fail(_test_id, "GET / returned " + code.string())
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    match ResponseParser.find_header_value(bytes, "connection")
    | let value: String =>
      let lower = value.lower()
      if lower.contains("close") then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "Connection header was \"" + value + "\" (expected to contain \"close\")")
      end
    | None =>
      _reporter.fail(_test_id,
        "no Connection header in response — server should advertise \"close\"")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
