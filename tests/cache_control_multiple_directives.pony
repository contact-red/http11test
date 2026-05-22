use "net"
use "../wire"
use "../runner"

actor CacheControlMultipleDirectives is WireCallback
  """
  RFC 9111 §5.2: Cache-Control is a comma-separated list of cache
  directives. A complex value like `max-age=0, no-cache, no-store,
  must-revalidate, private` is common from browsers behind force-
  reload. Server must accept the full list.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9111-5.2-02-multiple-directives"

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
      s.append("\r\nCache-Control: max-age=0, no-cache, no-store, must-revalidate, private\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "multi-directive Cache-Control returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
