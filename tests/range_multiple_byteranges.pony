use "net"
use "../wire"
use "../runner"

actor RangeMultipleByteranges is WireCallback
  """
  `Range: bytes=0-99, 200-299` (multiple ranges) - the server may
  respond 206 with multipart/byteranges body, 206 with combined range,
  200 (fall back), or 416 (refuse). Any non-5xx is acceptable.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-14.1.2-02-multiple-ranges"

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
      s.append("\r\nRange: bytes=0-99, 200-299, 500-599\r\n")
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
          "multi-range returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
