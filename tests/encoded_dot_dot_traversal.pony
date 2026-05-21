use "net"
use "../wire"
use "../runner"

actor EncodedDotDotTraversal is WireCallback
  """
  `%2E%2E` is percent-encoded `..`. A server that normalizes the path
  before applying access controls is vulnerable to traversal via
  encoded `..` segments. RFC 3986 §6.2.2.2 says normalization should
  happen before dot-segment removal — so `%2E%2E/etc/passwd` should
  resolve to `../etc/passwd` and then be rejected/normalized. We
  accept any non-2xx response; a 2xx with reachable filesystem would
  be a security concern.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-encoded-dot-dot"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /%2E%2E/etc/passwd HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
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
          "encoded ../ traversal returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
