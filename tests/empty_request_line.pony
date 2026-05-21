use "net"
use "../wire"
use "../runner"

actor EmptyRequestLine is WireCallback
  """
  Sending an empty request-line (just `\\r\\n`) before a valid request
  is allowed per RFC 9112 §2.2 — "In the interest of robustness, a
  server that is expecting to receive and parse a request-line SHOULD
  ignore at least one empty line (CRLF) received prior to the
  request-line." But several empty lines should still eventually
  yield a request or get rejected — not hang.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-2.2-08-multiple-empty-lines"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("\r\n\r\n\r\nGET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // Either 2xx (tolerant, the leading CRLFs are ignored) or 4xx
      // (strict — only 1 empty line tolerated) is acceptable.
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "multiple leading CRLFs returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
