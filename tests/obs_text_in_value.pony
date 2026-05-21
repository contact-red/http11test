use "net"
use "../wire"
use "../runner"

actor ObsTextInValue is WireCallback
  """
  RFC 9110 §5.5: field-vchar allows obs-text (0x80-0xFF). Latin-1
  characters and arbitrary high-bit bytes are technically valid in
  header values. Server must accept (or treat as opaque).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.5-04-obs-text"

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
        .>append("\r\nX-Latin1: caf")
        .>push(0xE9)  // 'é' in Latin-1
        .>append("\r\n")
        .>append("Connection: close\r\n\r\n")
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "obs-text in header value returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
