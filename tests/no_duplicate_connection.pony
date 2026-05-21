use "net"
use "../wire"
use "../runner"

actor NoDuplicateConnection is WireCallback
  """
  RFC 9110 §7.6.1 / §5.3: although a recipient MUST accept multiple
  Connection header fields and merge them by comma, an origin server's
  response should emit at most one Connection header. We probe with a
  request that asks for `Connection: close` and check the response only
  has one Connection header (or zero, since close on HTTP/1.0-style
  short response can also be signalled by other framing).
  """
  let _reporter: Reporter
  let _test_id: String = "interop-no-duplicate-connection-resp"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 if (code >= 200) and (code < 300) =>
      let n = ResponseParser.count_header(bytes, "connection")
      if n <= 1 then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "response contained " + n.string() + " Connection headers")
      end
    | let code: U16 =>
      _reporter.fail(_test_id, "non-2xx status " + code.string())
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
