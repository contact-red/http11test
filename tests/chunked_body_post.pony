use "net"
use "../wire"
use "../runner"

actor ChunkedBodyPost is WireCallback
  """
  POST / with Transfer-Encoding: chunked and a single 5-byte chunk
  followed by terminator. Probes the server's chunked decoder.
  Acceptable outcomes: 2xx (consumed), 4xx (rejected), 501 (TE not
  supported). A hang or 5xx indicates a chunked-parser bug.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-chunked-body-post"

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
      s.append("5\r\nhello\r\n")
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
          "chunked POST returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
