use "net"
use "../wire"
use "../runner"

actor RangeSuffix is WireCallback
  """
  `Range: bytes=-100` is suffix-range (last 100 bytes). RFC 9110 §14.1.2.
  Server returns 206 if supported, 200 if not, or 416 if too large.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-14.1.2-04-suffix-range"

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
      s.append("\r\nRange: bytes=-100\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if ((code >= 200) and (code < 300)) or (code == 416) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "Range: bytes=-100 returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
