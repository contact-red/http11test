use "net"
use "../wire"
use "../runner"

actor NoDuplicateDate is WireCallback
  """
  Per RFC 9110 §6.6.1, an origin server SHOULD include exactly one Date
  header field in any non-1xx response. We check that, when Date is
  present, it isn't duplicated (zero occurrences is acceptable for
  servers that opt out per the rare exceptions).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-6.6.1-03-no-duplicate-date-resp"

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
      let n = ResponseParser.count_header(bytes, "date")
      if n <= 1 then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "response contained " + n.string() + " Date headers")
      end
    | let code: U16 =>
      _reporter.fail(_test_id, "non-2xx status " + code.string())
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
