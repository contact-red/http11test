use "net"
use "../wire"
use "../runner"

actor PercentCrlfInPath is WireCallback
  """
  `%0D%0A` is percent-encoded CRLF. If the server decodes the path
  before logging or further processing, an unguarded log writer could
  end up with injected log lines. The HTTP layer should at minimum
  not interpret the decoded CRLF as a request boundary.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-2.1-01-percent-crlf-in-path"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /path%0D%0Ainjected HTTP/1.1\r\nHost: ")
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
          "%0D%0A in path returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
