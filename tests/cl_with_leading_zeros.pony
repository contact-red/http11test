use "net"
use "../wire"
use "../runner"

actor ClWithLeadingZeros is WireCallback
  """
  RFC 9110 §8.6: Content-Length is `1*DIGIT`. Leading zeros are
  technically valid (`007` parses as 7). Server should accept.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-cl-leading-zeros"

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
      s.append("\r\nContent-Length: 007\r\n")
      s.append("Connection: close\r\n\r\nhellooo")
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
          "CL: 007 returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
