use "net"
use "../wire"
use "../runner"

actor TruncatedPercentEncoding is WireCallback
  """
  `%2` (one hex digit after `%`) is an incomplete percent-encoding.
  RFC 3986 says `%` must be followed by exactly two HEXDIG. Strict
  parsers return 400; lenient ones may treat opaquely or 404.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-2.1-06-truncated-pct-encoding"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /a%2 HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
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
          "truncated %-encoding returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
