use "net"
use "../wire"
use "../runner"

actor GetHasDate is WireCallback
  """
  RFC 9110 §6.6.1: "An origin server MUST send a Date header field in
  all 2xx (Successful), 3xx (Redirection), and 4xx (Client Error)
  responses." (Exception: 1xx and 5xx may omit.) Stallion's library
  does not auto-emit Date — this is a hard MUST violation for any
  server operating as origin.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-6.6.1-01-origin-must-date"

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
    | let code: U16 if (code >= 200) and (code < 500) =>
      if ResponseParser.count_header(bytes, "date") >= 1 then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "origin server response has no Date header (MUST per §6.6.1)")
      end
    | let code: U16 =>
      _reporter.fail(_test_id, "unexpected status " + code.string())
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
