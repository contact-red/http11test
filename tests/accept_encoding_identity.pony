use "net"
use "../wire"
use "../runner"

actor AcceptEncodingIdentity is WireCallback
  """
  Per rfc9110-12.5.3, `identity` (no transformation) is always
  acceptable. A client signalling `Accept-Encoding: identity` is
  effectively opting out of compression. The server must still return
  the resource — content-coding negotiation can't fail when identity
  is in the accept set.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-accept-encoding-identity"

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
      s.append("\r\nAccept-Encoding: identity\r\nConnection: close\r\n\r\n")
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
          "GET with Accept-Encoding: identity returned " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
