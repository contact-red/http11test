use "net"
use "../wire"
use "../runner"

actor PatchWithBody is WireCallback
  """
  PATCH / with a small JSON body. PATCH (RFC 5789) is widely supported
  but not all servers implement it. Acceptable: 2xx, 4xx, or 501.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc5789-2-01-patch-method"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("PATCH / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nContent-Type: application/json\r\n")
      s.append("Content-Length: 13\r\n")
      s.append("Connection: close\r\n\r\n{\"hello\":true}")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id, "PATCH returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
