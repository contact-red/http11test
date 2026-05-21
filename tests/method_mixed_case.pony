use "net"
use "../wire"
use "../runner"

actor MethodMixedCase is WireCallback
  """
  RFC 9110 §9.1: "The method token is case-sensitive because it might
  be used as a gateway to object-based systems with case-sensitive
  method names." `GeT` is not equivalent to `GET`. A strict server
  responds 501 (Not Implemented) or 400. A lenient server may accept
  as GET; that's a SHOULD-grade nonconformance.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.1-01-method-case-sensitive"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GeT / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // Strict (correct): 4xx or 501. Lenient (incorrect): 2xx.
      if (code >= 400) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "mixed-case method 'GeT' returned " + code.string()
            + " — method should be treated case-sensitively")
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
