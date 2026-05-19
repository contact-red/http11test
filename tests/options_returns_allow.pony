use "net"
use "../wire"
use "../runner"

actor OptionsReturnsAllow is WireCallback
  """
  Covers rfc9110-9.3.7-01 (SHOULD): a server generating a successful
  response to OPTIONS SHOULD send any header that might indicate
  optional features implemented by the server and applicable to the
  target resource. The most universal such header is `Allow`, which
  lists permitted methods.

  We send OPTIONS / and FAIL if no Allow header is present in the
  response. (Servers free-routing every method to one handler still
  ought to advertise that fact.)
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.3.7-01"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("OPTIONS / HTTP/1.1\r\nHost: ")
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
          "OPTIONS / returned " + code.string() + " (target should answer 2xx)")
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    match ResponseParser.find_header_value(bytes, "allow")
    | let _: String =>
      _reporter.pass(_test_id)
    | None =>
      _reporter.fail(_test_id,
        "response to OPTIONS / has no Allow header")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
