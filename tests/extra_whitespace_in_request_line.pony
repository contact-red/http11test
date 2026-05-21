use "net"
use "../wire"
use "../runner"

actor ExtraWhitespaceInRequestLine is WireCallback
  """
  Per rfc9112-3-01 (MAY), recipients MAY treat multiple whitespace
  characters in the request-line as equivalent to single SP separators.
  Some servers reject; others normalize. We send `GET  /  HTTP/1.1`
  (double spaces) and accept either 2xx (normalized) or 400 (strict
  rejection).
  """
  let _reporter: Reporter
  let _test_id: String = "interop-extra-ws-request-line"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET  /  HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // Both compliance positions allowed: normalize (2xx) or reject (4xx).
      if ((code >= 200) and (code < 300)) or ((code >= 400) and (code < 500)) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "GET with double-space separators returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
