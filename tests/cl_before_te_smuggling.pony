use "net"
use "../wire"
use "../runner"

actor ClBeforeTeSmuggling is WireCallback
  """
  Same TE/CL conflict, opposite order. Some buggy parsers honor
  whichever header came LAST, others honor whichever came FIRST —
  the inconsistency is the actual smuggling vector when two HTTP
  components disagree.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-6.1-04-cl-before-te"

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
      s.append("\r\nContent-Length: 5\r\n")
      s.append("Transfer-Encoding: chunked\r\n")
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
          "CL+TE returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
