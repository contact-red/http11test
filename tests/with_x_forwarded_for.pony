use "net"
use "../wire"
use "../runner"

actor WithXForwardedFor is WireCallback
  """
  `X-Forwarded-For` is the de-facto standard for proxy chains. Any
  server fronted by a load balancer or reverse proxy sees this header.
  Must not break the request even if the server doesn't act on it.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-with-x-forwarded-for"

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
      s.append("\r\nX-Forwarded-For: 203.0.113.7, 198.51.100.42\r\n")
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
          "GET with X-Forwarded-For returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
