use "net"
use "../wire"
use "../runner"

actor NoDuplicateServer is WireCallback
  """
  Per RFC 9110 §10.2.4, a server MAY emit a Server header but it should
  not appear more than once. Test that response has at most one Server
  header — many servers omit it entirely (e.g., hyper, bandit), which is
  also fine.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-no-duplicate-server"

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
    | let code: U16 if (code >= 200) and (code < 300) =>
      let n = ResponseParser.count_header(bytes, "server")
      if n <= 1 then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "response contained " + n.string() + " Server headers")
      end
    | let code: U16 =>
      _reporter.fail(_test_id, "non-2xx status " + code.string())
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
