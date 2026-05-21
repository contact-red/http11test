use "net"
use "../wire"
use "../runner"

actor ChunkedExtensionEmpty is WireCallback
  """
  RFC 9112 §7.1.1: chunk-ext begins with `;`. The grammar allows an
  extension with empty name (`;`) or empty value (`;name=`). We send
  `5;\\r\\n` — semicolon with nothing after — and verify the server
  decodes the chunk and responds normally.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-chunked-extension-empty"

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
      s.append("\r\nTransfer-Encoding: chunked\r\n")
      s.append("Connection: close\r\n\r\n")
      s.append("5;\r\nhello\r\n")
      s.append("0\r\n\r\n")
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
          "chunked w/ empty extension returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
