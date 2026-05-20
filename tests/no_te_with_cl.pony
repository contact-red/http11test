use "net"
use "../wire"
use "../runner"

actor NoTeWithCl is WireCallback
  """
  Covers rfc9112-6.2-01 (MUST NOT): a sender MUST NOT send a
  Content-Length header in a message that also contains a Transfer-
  Encoding header. The two framing mechanisms conflict — a response
  with both is a known request-smuggling vector. We verify the server
  emits at most one of the two on a normal GET / response.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-6.2-01"

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

    if has_cl and has_te then
      _reporter.fail(_test_id,
        "response carries both Content-Length and Transfer-Encoding")
    else
      _reporter.pass(_test_id)
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
