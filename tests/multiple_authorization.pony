use "net"
use "../wire"
use "../runner"

actor MultipleAuthorization is WireCallback
  """
  RFC 9110 §11: multiple auth

  Multiple Authorization headers are technically allowed by the
  message grammar but semantically ambiguous. Servers MAY reject or
  MAY use only the first/last. We accept any HTTP response.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-11-01-multiple-auth"

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
      s.append("\r\nAuthorization: Bearer token1\r\n")
      s.append("Authorization: Basic dXNlcjpwYXNz\r\n")
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
          "multiple Authorization headers returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
