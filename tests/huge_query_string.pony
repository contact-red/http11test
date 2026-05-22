use "net"
use "../wire"
use "../runner"

actor HugeQueryString is WireCallback
  """
  RFC 3986 §3.4: huge query

  A 4-KB query string. Within typical limits for big-search forms,
  analytics URLs, or token-encoded payloads. Server must accept.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.4-03-huge-query"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /?q=")
      var i: USize = 0
      while i < 4000 do
        s.append("x")
        i = i + 1
      end
      s.append(" HTTP/1.1\r\nHost: ")
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
          "4KB query returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
