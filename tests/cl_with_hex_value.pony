use "net"
use "../wire"
use "../runner"

actor ClWithHexValue is WireCallback
  """
  RFC 9110 §8.6: Content-Length is `1*DIGIT` — decimal only. A hex-
  looking value like `0x5` must be rejected as it contains non-digit
  characters (`x`, `a`-`f`).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-8.6-06-hex-cl"

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
      s.append("\r\nContent-Length: 0x5\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 400) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "Content-Length: 0x5 returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
