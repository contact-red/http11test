use "net"
use "../wire"
use "../runner"

actor MethodVeryLongName is WireCallback
  """
  RFC 9110 §9.1 method is a token; max length is implementation-
  defined. A 40-char method name should either be parsed as an
  unknown method (501) or rejected as too long (431). Anything else
  is a finding.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.1-07-very-long-method"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("SUBSCRIBE-TO-MULTIPLE-FEEDS-AND-EVENTS-X / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 400) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "40-char method returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
