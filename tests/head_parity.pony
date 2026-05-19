use "net"
use "../wire"
use "../runner"

actor HeadParityRunner is WireCallback
  """
  Covers rfc9110-9.3.2-01: HEAD is identical to GET except the server MUST
  NOT send content. We send HEAD / and assert that the bytes after the
  CRLF CRLF header terminator are empty.

  This is a custom test shape (assertion on the body length, not the
  status code) so it isn't a RejectSpec — it's its own actor.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.3.2-01"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("HEAD / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    // First verify the response is a sane 2xx; if the server doesn't
    // support HEAD on /, the test isn't meaningful.
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code < 200) or (code >= 300) then
        _reporter.fail(_test_id,
          "HEAD / returned " + code.string() + " — test target should serve 2xx")
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    match ResponseParser.body_offset(bytes)
    | let offset: USize =>
      let body_len = bytes.size() - offset
      if body_len == 0 then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "HEAD response carried " + body_len.string() + " body bytes")
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
