use "net"
use "../wire"
use "../runner"

actor NoHostHeader is WireCallback
  """
  RFC 9112 §3.2: "A client MUST send a Host header field in all
  HTTP/1.1 request messages." Strict servers reject 400. Already
  tested by `rfc9112-3.2-06-missing` for general handling; this is
  paired form using a different framing.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-3.2-08-no-host-paired"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nUser-Agent: test\r\n")
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
          "no Host returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
