use "net"
use "../wire"
use "../runner"

actor LowercaseMethod is WireCallback
  """
  `get / HTTP/1.1` — RFC 9110 §9.1 says methods are case-sensitive. A
  strict server should treat "get" as unknown method (501/405) or
  malformed (400). A lenient server may accept it and route as GET
  (200). All three outcomes are documented.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.1-06-lowercase-method"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("get / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // Any well-formed response is acceptable; 501 Not Implemented is
      // the spec-correct answer for an unknown method.
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "lowercase method returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
