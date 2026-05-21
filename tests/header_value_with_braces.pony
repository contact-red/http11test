use "net"
use "../wire"
use "../runner"

actor HeaderValueWithBraces is WireCallback
  """
  JSON-shaped header values (`{"key": "value"}`) are increasingly
  common (e.g. structured logging trace context). Curly braces are
  VCHARs per RFC 9110 §5.5 grammar and so are legal in field-content.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-header-value-braces"

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
      s.append("\r\nX-Trace-Context: {\"trace\":\"abc\",\"span\":\"def\"}\r\n")
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
          "header value with braces returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
