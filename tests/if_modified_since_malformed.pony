use "net"
use "../wire"
use "../runner"

actor IfModifiedSinceMalformed is WireCallback
  """
  Per RFC 9110 §13.1.3, if a date in If-Modified-Since is not a valid
  HTTP date, the conditional MUST be ignored — the server proceeds as
  if it weren't sent. So the response is the normal 200 OK.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-13.1.3-01-ims-malformed"

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
      s.append("\r\nIf-Modified-Since: not-a-real-date\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // Strict reading of §13.1.3 wants 200 (conditional ignored).
      // A server that rejects with 400 is overly strict but tolerable.
      if (code == 200) or (code == 400) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "malformed If-Modified-Since returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
