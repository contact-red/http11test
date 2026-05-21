use "net"
use "../wire"
use "../runner"

actor BareCrInValue is WireCallback
  """
  RFC 9110 §5.5: field-content uses field-vchar = VCHAR / obs-text.
  CR (0x0D) is neither a VCHAR (0x21-0x7E) nor obs-text (0x80-0xFF),
  so it must not appear inside a header value. A bare CR in a value
  could be used as a request-smuggling vector (a careless parser might
  treat it as a line terminator). Server should reject with 400.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.5-02-bare-cr-in-value"

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
        .>push(0x0D)
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
          "bare CR in header value returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
