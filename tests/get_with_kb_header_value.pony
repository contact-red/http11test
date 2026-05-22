use "net"
use "../wire"
use "../runner"

actor GetWithKbHeaderValue is WireCallback
  """
  RFC 9110 §5.5: kb value

  Send a single header with a 4-KB value. Common for big-cookie jars
  and JWT-style tokens. Server should accept up to its configured
  limit; over-the-limit responses with 431.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.5-18-kb-value"

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
      s.append("\r\nX-Big: ")
      var i: USize = 0
      while i < 4000 do
        s.append("x")
        i = i + 1
      end
      s.append("\r\nConnection: close\r\n\r\n")
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
          "4KB header value returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
