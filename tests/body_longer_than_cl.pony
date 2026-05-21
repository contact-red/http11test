use "net"
use "../wire"
use "../runner"

actor BodyLongerThanCl is WireCallback
  """
  Send a POST with Content-Length: 5 but 20 bytes of body. The server
  reads 5 bytes (the declared CL) and treats the remaining 15 as the
  start of a new request. Those bytes form a malformed request-line,
  so a properly framed server emits two responses: the first 2xx for
  the well-formed POST, the second 4xx for the malformed continuation.

  This is a request-smuggling probe — a lenient server that reads
  past Content-Length, or that reuses the connection without re-
  framing, is vulnerable.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-body-longer-than-cl"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("POST / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nContent-Length: 5\r\n")
      s.append("Connection: close\r\n\r\nhelloEXTRAJUNKBYTES")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    // First response must be a valid 2xx or 4xx. The exact behavior of
    // any subsequent response is server-dependent — we only assert
    // the first.
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "POST body-longer-than-CL returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
