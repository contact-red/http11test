use "net"
use "../wire"
use "../runner"

actor MethodAllDigits is WireCallback
  """
  RFC 9110 §9.1: method = token; DIGIT ∈ tchar. A method that's all
  digits (`123`) is syntactically valid but semantically meaningless.
  Server should respond 501 Not Implemented or 400.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.1-08-all-digit-method"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("123 / HTTP/1.1\r\nHost: ")
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
          "all-digit method returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
