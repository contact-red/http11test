use "net"
use "../wire"
use "../runner"

actor NegotiateAuthorization is WireCallback
  """
  RFC 4559: `Authorization: Negotiate <SPNEGO-base64>` for Kerberos/
  GSS-API. Most non-Windows servers don't implement Negotiate, but
  they should accept the header without failing.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc4559-4-01-negotiate-auth"

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
      s.append("\r\nAuthorization: Negotiate YIIDSwYGKwYBBQUCo\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "Negotiate auth returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
