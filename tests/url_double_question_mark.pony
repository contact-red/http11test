use "net"
use "../wire"
use "../runner"

actor UrlDoubleQuestionMark is WireCallback
  """
  `GET /path??q=1 HTTP/1.1` — only the FIRST `?` is the query delimiter;
  subsequent `?` chars are part of the query value (RFC 3986 §3.4
  permits any pchar / "/" / "?" in the query). Server must accept.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.4-08-double-question-mark"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /??q=1 HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "double-`?` in URL returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
