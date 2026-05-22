use "net"
use "../wire"
use "../runner"

actor HeaderValueWithParens is WireCallback
  """
  RFC 9110 §5.6.5: header values may contain `comment` syntax — text
  inside `(...)`. User-Agent strings routinely use this:
  `Mozilla/5.0 (X11; Linux x86_64)`. Server must accept and pass
  through.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.5-11-value-with-parens"

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
      s.append("\r\nUser-Agent: TestBot/1.0 (test runner; +https://example.com)\r\n")
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
          "header value with comment returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
