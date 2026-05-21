use "net"
use "../wire"
use "../runner"

actor OptionsWithBody is WireCallback
  """
  RFC 9110 §9.3.7: OPTIONS may carry a body if it includes a valid
  Content-Length or Transfer-Encoding. The server must consume the
  body (else the next pipelined request would be misframed) and
  respond normally.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-options-with-body"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("OPTIONS / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nContent-Type: text/plain\r\nContent-Length: 4\r\n")
      s.append("Connection: close\r\n\r\nbody")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "OPTIONS with body returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
