use "net"
use "../wire"
use "../runner"

actor PathWithCurlyBraces is WireCallback
  """
  RFC 3986 §2.3: curly braces (`{`, `}`) are NOT in the unreserved /
  sub-delim set — they must be percent-encoded. A path like
  `/api/{id}/details` (common in URL templates) is malformed when
  sent over the wire. Strict servers reject 400; lenient servers
  accept opaquely.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.3-12-curly-braces"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /api/{id}/details HTTP/1.1\r\nHost: ")
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
          "path with curly braces returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
