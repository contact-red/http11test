use "net"
use "../wire"
use "../runner"

actor WithClientDate is WireCallback
  """
  Per RFC 9110 §6.6.1-06, a user agent MAY send a `Date` header in a
  request. Some monitoring agents and synthetic probes do this. The
  server must accept; semantics are server's discretion.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-with-client-date"

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
      s.append("\r\nDate: Sun, 06 Nov 1994 08:49:37 GMT\r\n")
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
          "GET with client Date returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
