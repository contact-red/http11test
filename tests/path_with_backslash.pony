use "net"
use "../wire"
use "../runner"

actor PathWithBackslash is WireCallback
  """
  Backslash is not in the URI pchar set (RFC 3986 §3.3). Windows
  clients sometimes emit it by mistake when converting filesystem
  paths. Strict servers reject 400; lenient ones accept.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.3-05-path-with-backslash"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /a\\b/c HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "path with backslash returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
