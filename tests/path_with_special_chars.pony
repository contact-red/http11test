use "net"
use "../wire"
use "../runner"

actor PathWithSpecialChars is WireCallback
  """
  Per RFC 3986, path segments may contain unreserved chars + sub-delims:
  `!$&'()*+,;=` along with alpha, digit, `-`, `.`, `_`, `~`, `:`, `@`,
  `/`. We send a path with several of these to ensure the server's URI
  parser doesn't reject them.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.3-13-sub-delims"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /a-b_c.d!e$f&g'h(i)j*k+l,m;n=o:p@q/r HTTP/1.1\r\nHost: ")
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
          "path with sub-delims returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
