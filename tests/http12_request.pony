use "net"
use "../wire"
use "../runner"

actor Http12Request is WireCallback
  """
  RFC 9112 §2.5: HTTP-version is "HTTP/1.1" or "HTTP/1.0" — `HTTP/1.2`
  is not a defined HTTP/1.x version. Per §2.5, a recipient SHOULD send
  505 (HTTP Version Not Supported) if it does not support the requested
  version. Stricter parsers may also reject as 400 (malformed
  request).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-2.5-01-http12"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.2\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // Either 400 (treat as malformed) or 505 (version not supported)
      // is correct. Anything else, including a 200, is a finding.
      if (code == 400) or (code == 505) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "HTTP/1.2 returned " + code.string() + " (expected 400 or 505)")
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
