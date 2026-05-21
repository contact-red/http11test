use "net"
use "../wire"
use "../runner"

actor ConnectMethod is WireCallback
  """
  RFC 9110 §9.3.6: CONNECT establishes a tunnel and uses authority-
  form request-target (`CONNECT example.com:443 HTTP/1.1`). An origin
  server that is not a tunnel proxy should respond 400, 405, or 501.
  We send a CONNECT request and accept any well-formed non-2xx (a 2xx
  would imply the server thinks it's tunneling, which is wrong here).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.3.6-01-connect-origin"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("CONNECT example.com:443 HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // 4xx or 5xx are correct here; a 2xx would indicate the server
      // mistakenly thinks it's a tunnel proxy.
      if (code >= 400) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "CONNECT to origin server returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
