use "net"
use "../wire"
use "../runner"

actor HeaderValueLeadingOws is WireCallback
  """
  RFC 9110 §5.5 / 5.6.3: leading OWS between the field-name's colon
  and the field-value is optional but allowed; servers must strip it
  before evaluating the value. A different test (`no_ows_after_colon`)
  probes the zero-OWS case; this one probes the extra-OWS case.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.5-14-extra-leading-ows"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost:   ")
      s.append(host)
      s.append("\r\nConnection:   close\r\n\r\n")
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
          "GET with extra leading OWS returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
