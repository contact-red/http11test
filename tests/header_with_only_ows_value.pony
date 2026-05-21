use "net"
use "../wire"
use "../runner"

actor HeaderWithOnlyOwsValue is WireCallback
  """
  RFC 9110 §5.5: a field value may consist entirely of OWS (after the
  colon-SP, all that follows is whitespace, trimmed to empty). Many
  servers conflate "all-OWS" with "empty value" and accept; some
  reject. We send `X-Empty:    \\r\\n` (spaces only after the colon)
  and accept either.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-header-all-ows-value"

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
      s.append("\r\nX-Empty:    \r\n")
      s.append("Connection: close\r\n\r\n")
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
          "all-OWS header value returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
