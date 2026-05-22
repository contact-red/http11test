use "net"
use "../wire"
use "../runner"

actor HeaderValueWithSemicolons is WireCallback
  """
  RFC 9110 §5.5: value with semicolons

  Header values can carry parameters separated by `;` — Cookie,
  Cache-Control, Content-Type are common examples. The server must
  pass through opaque values without splitting on `;`.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.5-13-value-with-semicolons"

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
      s.append("\r\nX-Test: a; b=1; c=2; d=\"e\"\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "semicolon-separated value returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
