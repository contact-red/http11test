use "net"
use "../wire"
use "../runner"

actor DoubleTeChunkedHeader is WireCallback
  """
  Two separate `Transfer-Encoding: chunked` header lines. RFC 9110
  §5.3 says multiple field lines with the same name are equivalent to
  a single line with comma-joined values — so the result is
  `chunked, chunked`. Per RFC 9112 §6.1, chunked may not appear twice
  (each transfer-coding listed must be unique). Strict servers may
  reject; lenient servers tolerate. Acceptance is any non-2xx OR a
  successful 2xx if treated as plain `chunked` (with the body framed
  correctly).
  """
  let _reporter: Reporter
  let _test_id: String = "interop-double-te-chunked"

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
      s.append("Transfer-Encoding: chunked\r\n")
      s.append("Connection: close\r\n\r\n0\r\n\r\n")
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
          "double TE: chunked returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
