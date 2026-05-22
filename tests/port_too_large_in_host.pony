use "net"
use "../wire"
use "../runner"

actor PortTooLargeInHost is WireCallback
  """
  TCP/UDP ports are unsigned 16-bit (0-65535). A value > 65535 like
  `:99999` is not a valid port. Strict servers respond 400.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.2.2-16-port-too-large"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: example.com:99999\r\n")
      s.append("Connection: close\r\n\r\n")
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
          "Host with port > 65535 returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
