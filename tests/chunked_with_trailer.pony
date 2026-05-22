use "net"
use "../wire"
use "../runner"

actor ChunkedWithTrailer is WireCallback
  """
  RFC 9112 §7.1.2 allows trailer fields after the terminating chunk.
  We send a trailer header `X-Trailer-Test: 1` between the last-chunk
  marker and the final CRLF.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-7.1.2-01-chunk-trailer"

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
      s.append("Trailer: X-Trailer-Test\r\n")
      s.append("Connection: close\r\n\r\n")
      s.append("5\r\nhello\r\n")
      s.append("0\r\nX-Trailer-Test: 1\r\n\r\n")
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
          "chunked w/ trailer POST returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
