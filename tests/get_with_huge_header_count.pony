use "net"
use "../wire"
use "../runner"

actor GetWithHugeHeaderCount is WireCallback
  """
  Send 80 distinct X-Header-N lines. Real-world deployments with many
  middlewares and tracing systems can accumulate this many headers.
  Server should accept up to its configured limit. Most servers cap
  somewhere between 64 and 256 headers; over-the-limit yields 431.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.3-05-many-distinct-headers"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\n")
      var i: USize = 0
      while i < 80 do
        s.append("X-Header-")
        s.append(i.string())
        s.append(": value")
        s.append(i.string())
        s.append("\r\n")
        i = i + 1
      end
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // 200 (accepted), 431 (too many), 413 (too large) all defensible.
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "80 headers returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
