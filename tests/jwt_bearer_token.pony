use "net"
use "../wire"
use "../runner"

actor JwtBearerToken is WireCallback
  """
  RFC 6750 §2.1: `Authorization: Bearer <token>` with a JWT-shaped
  token (three dot-separated base64url segments). Server must accept
  the opaque token without parsing.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc6750-2.1-01-jwt-bearer"

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
      s.append("\r\nAuthorization: Bearer ")
      s.append("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.")
      s.append("eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkphbmUiLCJpYXQiOjE1MTYyMzkwMjJ9.")
      s.append("dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U\r\n")
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
          "JWT bearer returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
