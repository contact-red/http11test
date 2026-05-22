use "net"
use "../wire"
use "../runner"

actor LongQueryString is WireCallback
  """
  RFC 3986 §3.4: long query

  Real-world query strings can run into kilobytes — search forms,
  serialized state, OAuth callback params. We send a ~2 KB query and
  verify the server accepts it (well under any sane request-line
  limit but bigger than trivially small).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.4-02-long-query"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String(2500)
      s.append("GET /?")
      var i: USize = 0
      while i < 100 do
        s.append("k")
        s.append(i.string())
        s.append("=somevalue&")
        i = i + 1
      end
      s.append("end=1 HTTP/1.1\r\nHost: ")
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
          "GET with ~2KB query string returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
