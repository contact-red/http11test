use "net"
use "../wire"
use "../runner"

actor MultipleConnectionLines is WireCallback
  """
  RFC 9110 §5.3: multi connection

  Covers rfc9110-5.3 (multiple field lines with the same name are
  equivalent to a single comma-joined value) intersecting with the
  Connection close semantics. We send TWO `Connection:` header lines —
  one with `close`, one with a benign extension token — and expect the
  server to read both and respect close.

  Both lines individually contain a sane close signal (the first is
  literally `close`), so even servers that take only the first line will
  PASS. The test is mainly probing that the server doesn't reject
  multi-line headers as malformed.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.3-01-multi-connection"

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
      s.append("\r\nConnection: close\r\n")
      s.append("Connection: x-extension\r\n")
      s.append("\r\n")
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
          "multi-line Connection returned " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
