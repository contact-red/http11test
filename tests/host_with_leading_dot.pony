use "net"
use "../wire"
use "../runner"

actor HostWithLeadingDot is WireCallback
  """
  RFC 3986 §3.2.2: leading dot fqdn

  `.example.com` (with leading dot) is a valid root-relative FQDN per
  DNS conventions. Server may treat as a normal host or reject;
  either is acceptable as long as it doesn't crash.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.2.2-17-leading-dot-fqdn"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: .example.com\r\n")
      s.append("Connection: close\r\n\r\n")
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
          "Host with leading dot returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
