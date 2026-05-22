use "net"
use "../wire"
use "../runner"

actor HeadWithContentLength is WireCallback
  """
  RFC 9110 §9.3.2: HEAD has no payload semantics. Clients sometimes
  send `Content-Length: 0` as a habit; server must accept and not
  attempt to read body bytes.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.3.2-06-head-with-cl"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("HEAD / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nContent-Length: 0\r\n")
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
          "HEAD with CL=0 returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
