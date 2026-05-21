use "net"
use "../wire"
use "../runner"

actor Http10ChunkedRejected is WireCallback
  """
  RFC 9112 §1.2 / §6.1: chunked transfer-coding is an HTTP/1.1+
  feature. A HTTP/1.0 request that uses `Transfer-Encoding: chunked`
  is malformed — server should reject with 400. A lenient server may
  treat as no body and process the request anyway.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-6.1-02-http10-chunked"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("POST / HTTP/1.0\r\nHost: ")
      s.append(host)
      s.append("\r\nTransfer-Encoding: chunked\r\n")
      s.append("Connection: close\r\n\r\n0\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 400) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "HTTP/1.0 with chunked returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
