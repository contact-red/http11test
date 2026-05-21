use "net"
use "../wire"
use "../runner"

actor DuplicateHostSameValue is WireCallback
  """
  RFC 9112 §3.2: "A client MUST send a Host header field in all
  HTTP/1.1 request messages." §5.3 says "A sender MUST NOT generate
  multiple field lines with the same field name in a message unless
  either the entire field value for that field is defined as a
  comma-separated list ... or the field is a well-known exception."
  Host has no list semantics, so multiple Host headers — even if
  identical — are malformed and server should reject.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-3.2-07-duplicate-host-same"

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
      s.append("\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 400) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "duplicate Host (same value) returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
