use "net"
use "../wire"
use "../runner"

actor HighBitInHeaderName is WireCallback
  """
  RFC 9110 §5.6.2 field-name is `token`, which uses tchar — ASCII only.
  A field-name with a high-bit (0x80+) byte is malformed. We send a
  byte (0xE9, the UTF-8 first byte for some Latin-1 chars) and expect
  a 4xx response.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.6.2-02-high-bit-field-name"

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
        .>append("\r\nX-")
        .>push(0xE9)
        .>append("bad: value\r\n")
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
          "high-bit byte in field-name returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
