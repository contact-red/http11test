use "net"
use "../wire"
use "../runner"

actor ConflictingConnectionLines is WireCallback
  """
  Two Connection headers with opposing values: `keep-alive` and
  `close`. Per RFC 9110 §7.6.1, when both `close` and `keep-alive`
  appear, the connection MUST close.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-7.6.1-01-conflicting-connection"

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
      s.append("\r\nConnection: keep-alive\r\n")
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
          "conflicting Connection returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
