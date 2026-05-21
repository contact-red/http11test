use "net"
use "../wire"
use "../runner"

actor RangeHeaderHandled is WireCallback
  """
  Browsers send `Range: bytes=N-M` for resumable downloads, video
  scrubbing, etc. Servers that support range return 206 Partial
  Content; servers that don't are allowed to ignore the header and
  return the full 200. Either is RFC-compliant; what's important is
  that the request doesn't error.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-range-header-handled"

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
      s.append("\r\nRange: bytes=0-1\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // 200 (ignored Range) or 206 (honored Range) are both compliant.
      if (code == 200) or (code == 206) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "GET with Range header returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
