use "net"
use "../wire"
use "../runner"

actor NoOwsAfterColon is WireCallback
  """
  Per RFC 9110 §5.5 / 5.6.3, the OWS after `:` in a header is optional.
  Many proxies normalize headers by stripping that space; servers MUST
  accept the resulting compact form. We send `Host:host` and `Connection:close`
  with no whitespace after either colon and verify the server still
  returns 2xx.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.5-01-compact"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost:")
      s.append(host)
      s.append("\r\nConnection:close\r\n\r\n")
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
          "compact-header GET / returned " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
