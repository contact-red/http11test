use "net"
use "../wire"
use "../runner"

actor PathWithSemicolonParams is WireCallback
  """
  Path-style parameters (`;name=value`) are part of the URI grammar
  (RFC 3986 §3.3 — they're sub-delims). Java servlet routing
  historically uses `;jsessionid=...`. Server must accept the path
  without splitting on semicolons.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.3-10-path-with-semicolon"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /res;jsessionid=abc123 HTTP/1.1\r\nHost: ")
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
          "path with semicolon params returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
