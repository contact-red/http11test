use "net"
use "../wire"
use "../runner"

actor HeaderValueLeadingTab is WireCallback
  """
  RFC 9110 §5.5: OWS may be HTAB or SP. A leading tab after the
  field-name colon should be stripped before evaluation. We send
  `X-Test:\\tvalue\\r\\n` and expect 2xx.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.5-10-leading-tab-ows"

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
      s.append("\r\nX-Test:\tvalue\r\n")
      s.append("Connection:\tclose\r\n\r\n")
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
          "tab-OWS in header returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
