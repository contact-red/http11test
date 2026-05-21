use "net"
use "../wire"
use "../runner"

actor DelInValue is WireCallback
  """
  RFC 9110 §5.5: VCHAR is 0x21-0x7E. DEL (0x7F) is not a VCHAR and
  not obs-text. Server should reject 400.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.5-03-del-in-value"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request: Array[U8] val = recover val
      let buf = Array[U8]
      buf.>append("GET / HTTP/1.1\r\nHost: ")
        .>append(host)
        .>append("\r\nX-Test: hel")
        .>push(0x7F)
        .>append("lo\r\n")
        .>append("Connection: close\r\n\r\n")
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 400) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "DEL byte in header value returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
