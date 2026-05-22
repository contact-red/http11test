use "net"
use "../wire"
use "../runner"

actor WithXCustomHeader is WireCallback
  """
  Application-defined `X-` headers must be tolerated by the server (RFC
  9110 §16.3 — extension fields). We use a long, dotted name.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-16.3.2-01-x-custom"

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
      s.append("\r\nX-Request-Id: 7c8a4f93-2d1e-4f6b-8c0a-1f4e6d2b3a9c\r\n")
      s.append("X-Forwarded-Proto: https\r\n")
      s.append("X-Application-Trace-Id: abcdef.123456\r\n")
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
          "GET with X- headers returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
