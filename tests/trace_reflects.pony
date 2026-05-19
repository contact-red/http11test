use "net"
use "../wire"
use "../runner"

actor TraceReflects is WireCallback
  """
  Covers rfc9110-9.3.8-01 (SHOULD): the final recipient of a TRACE
  request SHOULD reflect the message received back to the client as the
  body of a 200 response. The standard signal is a `Content-Type:
  message/http` header on the response.

  Browsers don't use TRACE (and it's often disabled for XST-attack
  reasons), so a FAIL here can be deliberate hardening as well as
  non-implementation. Useful divergence signal either way.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.3.8-01"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("TRACE / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code < 200) or (code >= 300) then
        _reporter.fail(_test_id,
          "TRACE / returned " + code.string()
            + " — server doesn't implement TRACE")
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    match ResponseParser.find_header_value(bytes, "content-type")
    | let value: String =>
      let lower = value.lower()
      if lower.contains("message/http") then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "Content-Type was \"" + value
            + "\" — TRACE not reflected as message/http")
      end
    | None =>
      _reporter.fail(_test_id,
        "TRACE response has no Content-Type — not reflected as message/http")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
