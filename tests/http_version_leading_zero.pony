use "net"
use "../wire"
use "../runner"

actor HttpVersionLeadingZero is WireCallback
  """
  RFC 9112 §2.5: HTTP-version = `HTTP-name "/" DIGIT "." DIGIT`. Each
  side of the dot is a single DIGIT — `HTTP/01.1` violates the
  grammar. Server should respond 400 or 505.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-2.5-05-leading-zero-version"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/01.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 400) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "HTTP/01.1 returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
