use "net"
use "../wire"
use "../runner"

actor PriorityHeader is WireCallback
  """
  RFC 9218: `Priority: u=1, i` is a structured-fields header for
  HTTP/2 and HTTP/3 priority signaling, but is sometimes sent on
  HTTP/1.1 too. Server must accept (and ignore on HTTP/1.1).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9218-2-01-priority-header"

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
      s.append("\r\nPriority: u=1, i\r\n")
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
          "Priority header returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
