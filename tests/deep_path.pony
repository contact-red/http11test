use "net"
use "../wire"
use "../runner"

actor DeepPath is WireCallback
  """
  Multi-segment URL paths (`/a/b/c/d/e`) are common in REST APIs and
  static-site layouts. Server must accept arbitrary path depth (within
  size limits). We use 20 segments.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-deep-path"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET ")
      var i: USize = 0
      while i < 20 do
        s.append("/segment")
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
      if (code >= 200) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "GET deep path returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
