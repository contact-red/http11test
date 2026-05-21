use "net"
use "../wire"
use "../runner"

actor ChunkedWithExtension is WireCallback
  """
  RFC 9112 §7.1.1 chunk-ext is OPTIONAL after chunk-size, separated by
  `;`. Servers MUST accept and ignore unknown chunk-extensions.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-chunked-with-extension"

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
      s.append("5;ext=value\r\nhello\r\n")
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
          "chunked w/ extension POST returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
