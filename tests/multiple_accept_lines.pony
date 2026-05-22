use "net"
use "../wire"
use "../runner"

actor MultipleAcceptLines is WireCallback
  """
  RFC 9110 §5.3: multiple field lines with the same name and a list-
  type field value are equivalent to a single comma-joined value.
  Accept is a list field, so two Accept headers should be treated the
  same as `Accept: text/html, text/plain`.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.3-01-multiple-list-lines"

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
      s.append("\r\nAccept: text/html\r\n")
      s.append("Accept: text/plain\r\n")
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
          "multiple Accept lines returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
