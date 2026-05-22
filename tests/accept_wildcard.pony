use "net"
use "../wire"
use "../runner"

actor AcceptWildcard is WireCallback
  """
  Covers basic content negotiation interop: `Accept: */*` MUST be
  honored as "any media type is acceptable". Used by every command-line
  tool, search-engine crawler, and headless browser. A server that
  refuses `*/*` would fail to serve clients that don't enumerate types.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-12.5.1-04-wildcard"

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
      s.append("\r\nAccept: */*\r\nConnection: close\r\n\r\n")
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
          "GET with `Accept: */*` returned " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
