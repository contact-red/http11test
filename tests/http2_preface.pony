use "net"
use "../wire"
use "../runner"

actor Http2Preface is WireCallback
  """
  An HTTP/2 client that doesn't know prior-knowledge HTTP/1.1 sends
  the HTTP/2 connection preface — `PRI * HTTP/2.0\\r\\n\\r\\nSM\\r\\n\\r\\n`.
  An HTTP/1.1-only server must reject (400 or 505). Crucially, it
  MUST NOT honor `PRI *` as if it were an HTTP/1.1 OPTIONS.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-2.5-04-http2-preface"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 400) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "HTTP/2 preface returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
