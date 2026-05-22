use "net"
use "../wire"
use "../runner"

actor AcceptMultipleTypes is WireCallback
  """
  Browsers send `Accept` with multiple weighted media ranges
  (`text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8`).
  We've already tested the realistic browser variant in browser-style;
  this one is narrower — just three explicit types with q-weights —
  to exercise the comma+semicolon list parser.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-12.5.1-01-multiple-types"

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
      s.append("\r\nAccept: application/json;q=0.9,text/plain;q=0.5,*/*;q=0.1\r\n")
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
          "GET with multi-type Accept returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
