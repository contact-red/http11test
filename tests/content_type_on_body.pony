use "net"
use "../wire"
use "../runner"

actor ContentTypeOnBody is WireCallback
  """
  Covers rfc9110-8.3-01 (SHOULD): a sender that generates a message
  containing content SHOULD generate a Content-Type header unless the
  intended media type is unknown to the sender. We GET / and, if the
  response has a non-empty body, check for a Content-Type header.
  Without it, browser content sniffing kicks in — a security and
  rendering hazard.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-8.3-01"

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
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code < 200) or (code >= 300) then
        _reporter.fail(_test_id,
          "GET / returned " + code.string())
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    // If there's no body, the SHOULD doesn't apply.
    match ResponseParser.body_offset(bytes)
    | let body_start: USize =>
      if (bytes.size() - body_start) == 0 then
        _reporter.skip(_test_id, "GET / response has no body — test inapplicable")
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    match ResponseParser.find_header_value(bytes, "content-type")
    | let _: String =>
      _reporter.pass(_test_id)
    | None =>
      _reporter.fail(_test_id,
        "response has body but no Content-Type header")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
