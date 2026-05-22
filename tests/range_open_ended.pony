use "net"
use "../wire"
use "../runner"

actor RangeOpenEnded is WireCallback
  """
  `Range: bytes=0-` is an open-ended range (from byte 0 to end). RFC
  9110 §14.1.2. Servers that don't support Range respond 200; those
  that do respond 206. Either is acceptable.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-14.1.2-03-open-ended"

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
      s.append("\r\nRange: bytes=0-\r\n")
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
          "Range: bytes=0- returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
