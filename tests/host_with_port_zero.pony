use "net"
use "../wire"
use "../runner"

actor HostWithPortZero is WireCallback
  """
  RFC 3986 §3.2.2: port zero

  TCP port 0 is reserved (cannot be bound by an application). Sending
  `Host: example.com:0` is a malformed authority. Strict servers
  respond 400.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.2.2-15-port-zero"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: example.com:0\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "Host with port 0 returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
