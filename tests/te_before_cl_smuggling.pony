use "net"
use "../wire"
use "../runner"

actor TeBeforeClSmuggling is WireCallback
  """
  Request-smuggling classic: send both `Transfer-Encoding: chunked`
  and `Content-Length` on the same request. RFC 9112 §6.1: a server
  that receives a request message with both MUST close the connection
  after responding, and either:
  - reject as malformed (RFC §6.1-15 strongly recommends), or
  - prefer Transfer-Encoding (§6.3)

  We send TE first, then CL. Servers that incorrectly use the CL
  framing are smuggling-vulnerable. Acceptance: any 4xx (rejected)
  or 2xx (TE used and chunked body parsed correctly).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-6.1-03-te-before-cl"

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
      s.append("\r\nTransfer-Encoding: chunked\r\n")
      s.append("Content-Length: 5\r\n")
      s.append("Connection: close\r\n\r\n0\r\n\r\n")
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
          "TE+CL returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
