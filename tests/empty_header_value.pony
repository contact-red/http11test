use "net"
use "../wire"
use "../runner"

actor EmptyHeaderValue is WireCallback
  """
  Per RFC 9110 §5.5 / 5.6.3, OWS-only or empty header values are
  syntactically valid. Real-world clients emit empty values for
  optional features they don't carry (`Referer:` when there's no
  referrer source, `X-Custom:` placeholders). Server must accept.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.5-05-empty-field-value"

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
      s.append("\r\nX-Empty: \r\nConnection: close\r\n\r\n")
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
          "GET with empty header value returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
