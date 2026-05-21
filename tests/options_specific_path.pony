use "net"
use "../wire"
use "../runner"

actor OptionsSpecificPath is WireCallback
  """
  RFC 9110 §9.3.7: OPTIONS for a specific path should return the
  methods Allowed for that resource. The response SHOULD include an
  Allow header listing the supported methods. Many frameworks omit
  Allow on OPTIONS, which is a SHOULD-level finding.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.3.7-02-options-path"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("OPTIONS /resource HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 if (code >= 200) and (code < 300) =>
      if ResponseParser.count_header(bytes, "allow") >= 1 then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "response to OPTIONS /resource has no Allow header")
      end
    | let code: U16 =>
      _reporter.fail(_test_id,
        "OPTIONS /resource returned " + code.string())
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
