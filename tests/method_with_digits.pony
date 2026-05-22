use "net"
use "../wire"
use "../runner"

actor MethodWithDigits is WireCallback
  """
  RFC 9110 §9.1: method is a token, and tchar permits DIGIT. So a
  method name like `GET2` is technically valid syntax even though no
  server implements it. Server should respond 501 (Not Implemented).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.1-04-method-with-digits"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET2 / HTTP/1.1\r\nHost: ")
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
          "GET2 method returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
