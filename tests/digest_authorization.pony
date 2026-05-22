use "net"
use "../wire"
use "../runner"

actor DigestAuthorization is WireCallback
  """
  `Authorization: Digest ...` (RFC 7616). Most non-Apache servers
  don't implement Digest auth, but they should still accept the
  header and respond normally (since the application decides what
  to do with it).
  """
  let _reporter: Reporter
  let _test_id: String = "interop-digest-authorization"

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
      s.append("\r\nAuthorization: Digest username=\"alice\", realm=\"test\", nonce=\"abc\", uri=\"/\", response=\"def\"\r\n")
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
          "Digest auth returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
