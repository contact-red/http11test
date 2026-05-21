use "net"
use "../wire"
use "../runner"

actor PathWithTilde is WireCallback
  """
  `~` is an unreserved URI character (RFC 3986 §2.3). Paths like
  `/~user/file.html` are common on Unix-y web servers. Must be
  accepted unchanged.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-path-with-tilde"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /~user/file.html HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "path with tilde returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
