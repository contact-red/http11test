use "net"
use "../wire"
use "../runner"

actor TeIdentityOnly is WireCallback
  """
  `Transfer-Encoding: identity` is the historical "no-op" coding (deprecated
  by RFC 9112 but still seen in the wild). With no body and the close
  signal, server should respond normally. We accept any HTTP response
  (200, 400, 501) — important property is that the server does not hang.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-te-identity-only"

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
      s.append("\r\nTransfer-Encoding: identity\r\n")
      s.append("Content-Length: 0\r\n")
      s.append("Connection: close\r\n\r\n")
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
          "TE: identity returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
