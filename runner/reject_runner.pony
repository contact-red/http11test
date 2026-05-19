use "net"
use "../wire"

actor RejectRunner is WireCallback
  """
  Executes one RejectSpec: open a TCP connection, send the spec's bytes,
  read the response, parse the status code, and report PASS / FAIL via the
  shared Reporter.
  """
  let _reporter: Reporter
  let _spec: RejectSpec

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    spec: RejectSpec,
    reporter: Reporter)
  =>
    _spec = spec
    _reporter = reporter
    WireClient(auth, host, service, _spec.request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if _spec.accepts(code) then
        _reporter.pass(_spec.id)
      else
        _reporter.fail(_spec.id,
          "expected " + _spec.expected_summary() + ", got " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_spec.id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_spec.id, reason)
