use "net"
use "../wire"
use "../runner"

actor ResponseHasFraming is WireCallback
  """
  Covers rfc9112-6.3-09 / rfc9110-8.6-07: every response with content
  needs explicit framing — either Content-Length or Transfer-Encoding.
  Without one, the client can't tell where the body ends except via
  connection close, which causes spurious "broken page" renders and
  cache misses in browsers.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-6.3-09"

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
        _reporter.fail(_test_id, "GET / returned " + code.string())
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    let has_cl =
      match ResponseParser.find_header_value(bytes, "content-length")
      | let _: String => true
      | None => false
      end

    let has_te =
      match ResponseParser.find_header_value(bytes, "transfer-encoding")
      | let _: String => true
      | None => false
      end

    if has_cl or has_te then
      _reporter.pass(_test_id)
    else
      _reporter.fail(_test_id,
        "response has neither Content-Length nor Transfer-Encoding")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
