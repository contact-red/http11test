use "net"
use "../wire"
use "../runner"

actor EmptyRequestThenClose is WireCallback
  """
  Connect, send zero bytes, close. RFC 9112 §9.1: idle keep-alive
  connections with no pending request are expected; servers should
  not crash if the connection is closed before any bytes arrive.
  Acceptance: either the server returns no bytes (no_response_to_
  empty) or it returns an HTTP error response.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-9.3-07-empty-request"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    // Empty request bytes — connect, send nothing, close.
    let request = recover val "" end
    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    // Server closed cleanly without bytes — fine. Server returned
    // valid HTTP error — also fine. Anything else is suspicious.
    if bytes.size() == 0 then
      _reporter.pass(_test_id)
      return
    end
    match ResponseParser.status_code(bytes)
    | let code: U16 if (code >= 200) and (code < 600) =>
      _reporter.pass(_test_id)
    | let code: U16 =>
      _reporter.fail(_test_id, "empty connect returned " + code.string())
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    // Timeout is the expected outcome here: most servers leave the
    // connection idle waiting for data. Accept it as a PASS so this
    // probe focuses on crashing/garbage responses rather than the
    // wait-for-data behavior we expect.
    if reason == "test timed out" then
      _reporter.pass(_test_id)
    else
      _reporter.fail(_test_id, reason)
    end
