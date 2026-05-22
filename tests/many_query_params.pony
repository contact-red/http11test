use "net"
use "../wire"
use "../runner"

actor ManyQueryParams is WireCallback
  """
  RFC 3986 §3.4: many params

  GET / with 30 distinct query parameters. Common for tracking-pixel,
  analytics, or filter URLs. Server must accept long-tail of `&a=b`
  pairs.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.4-04-many-params"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /?")
      var i: USize = 0
      while i < 30 do
        if i > 0 then s.append("&") end
        s.append("p")
        s.append(i.string())
        s.append("=v")
        s.append(i.string())
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
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "GET with 30 query params returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
