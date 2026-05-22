use "net"
use "../wire"
use "../runner"

actor PercentNullInPath is WireCallback
  """
  `%00` is a percent-encoded NUL byte. NUL bytes in paths often
  indicate injection attempts (truncating C-string filename handlers,
  etc.). A defensive server rejects with 400; a permissive one
  decodes opaquely and may 404. RFC 3986 doesn't forbid `%00` in
  paths but discourages it. We accept any non-2xx (treating 2xx as a
  finding worth investigating).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-2.1-05-percent-null"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /file%00.txt HTTP/1.1\r\nHost: ")
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
          "%00 in path returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
