use "net"
use "../wire"
use "../runner"

actor WithAuthorization is WireCallback
  """
  RFC 9110 §11.6.2: basic auth

  An `Authorization:` header on an unprotected resource must not break
  the response. (The server should serve normally — authorization is
  ignored when not required.) A server that returns 4xx for any
  Authorization header would break clients with stale stored creds.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-11.6.2-01-basic-auth"

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
      s.append("\r\nAuthorization: Bearer abc123token\r\n")
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
          "GET with Authorization on unprotected resource returned "
            + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
