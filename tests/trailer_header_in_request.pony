use "net"
use "../wire"
use "../runner"

actor TrailerHeaderInRequest is WireCallback
  """
  RFC 9110 §6.6.2: `Trailer` header field declares which fields
  appear in the chunked trailer section. We send a chunked POST
  with `Trailer: X-Trace-Id` and a body that includes the declared
  trailer at the end.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-6.6.2-01-trailer-header"

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
      s.append("\r\nTransfer-Encoding: chunked\r\n")
      s.append("Trailer: X-Trace-Id\r\n")
      s.append("Connection: close\r\n\r\n")
      s.append("5\r\nhello\r\n")
      s.append("0\r\nX-Trace-Id: abc123\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "Trailer header in request returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
