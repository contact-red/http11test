use "net"
use "../wire"
use "../runner"

actor ResponseHasServerHeader is WireCallback
  """
  RFC 9110 §10.2.4: "An origin server SHOULD generate a Server field
  in responses." Frameworks often omit this (delegating to the
  application), which is a SHOULD-level finding rather than a hard
  protocol violation.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-10.2.4-01-origin-server-header"

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
      if ResponseParser.count_header(bytes, "server") >= 1 then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "origin server response has no Server header")
      end
    | let code: U16 =>
      _reporter.fail(_test_id, "non-2xx status " + code.string())
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
