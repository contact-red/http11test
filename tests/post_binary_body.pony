use "net"
use "../wire"
use "../runner"

actor PostBinaryBody is WireCallback
  """
  RFC 9110 §8.3: Content-Type identifies the body media type. We
  send `application/octet-stream` with binary bytes (0x00..0xFF) as
  the body. Server must consume them via Content-Length and respond
  normally.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-8.3-03-binary-body"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request: Array[U8] val = recover val
      let buf = Array[U8]
      buf.>append("POST / HTTP/1.1\r\nHost: ")
        .>append(host)
        .>append("\r\nContent-Type: application/octet-stream\r\n")
        .>append("Content-Length: 256\r\n")
        .>append("Connection: close\r\n\r\n")
      var i: U16 = 0
      while i < 256 do
        buf.push(i.u8())
        i = i + 1
      end
      buf
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "POST binary body returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
