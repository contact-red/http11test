use "net"
use "../wire"
use "../runner"

actor ClWithTrailingSpace is WireCallback
  """
  Trailing OWS in header values must be stripped before parsing (RFC
  9110 §5.5). `Content-Length: 0    ` (with trailing spaces) is valid
  after trimming. Server must accept.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-8.6-11-cl-trailing-space"

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
      s.append("\r\nContent-Length: 0    \r\n")
      s.append("Connection: close\r\n\r\n")
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
          "CL with trailing space returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
