use "net"
use "../wire"
use "../runner"

actor TwoCookieHeaders is WireCallback
  """
  Two separate Cookie headers. RFC 6265 prefers a single Cookie header
  per request, but historical clients have sent multiples. Servers must
  accept (often by joining or by treating them as separate). RFC 9110
  §5.3 allows multiple field lines with the same name; Cookie is an
  exception that uses semicolons instead of commas — but multiple lines
  should still be tolerated.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc6265-5.4-02-two-cookie-headers"

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
      s.append("\r\nCookie: a=1\r\n")
      s.append("Cookie: b=2\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "two Cookie headers returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
