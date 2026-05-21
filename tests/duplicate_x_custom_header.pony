use "net"
use "../wire"
use "../runner"

actor DuplicateXCustomHeader is WireCallback
  """
  RFC 9110 §5.3: A recipient MAY combine multiple field lines with
  the same name into one. Sending the same custom header twice should
  yield a 2xx — the server need not error.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-duplicate-x-custom-header"

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
      s.append("\r\nX-Custom: alpha\r\n")
      s.append("X-Custom: beta\r\n")
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
          "duplicate X-Custom header returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
