use "net"
use "../wire"
use "../runner"

actor OptionsAsterisk is WireCallback
  """
  Covers rfc9112-3.2.4-02 (origin half): the last proxy in a request
  chain MUST send `OPTIONS *` when forwarding a server-wide OPTIONS. By
  implication, origin servers need to accept `*` as a request-target.
  We send `OPTIONS *` directly and assert the server responds with a
  successful (2xx) status rather than rejecting the request-target.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-3.2.4-02"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("OPTIONS * HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
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
          "OPTIONS * returned " + code.string()
            + " — server doesn't accept `*` as request-target")
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
