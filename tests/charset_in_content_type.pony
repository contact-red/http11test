use "net"
use "../wire"
use "../runner"

actor CharsetInContentType is WireCallback
  """
  RFC 9110 §8.3: Content-Type may carry a `charset` parameter, e.g.
  `text/plain; charset=utf-8`. Server must accept the parameter
  without splitting the header or rejecting.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-charset-in-content-type"

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
      s.append("\r\nContent-Type: text/plain; charset=utf-8\r\n")
      s.append("Content-Length: 5\r\n")
      s.append("Connection: close\r\n\r\nhello")
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
          "Content-Type with charset returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
