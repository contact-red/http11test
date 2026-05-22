use "net"
use "../wire"
use "../runner"

actor LongUserAgent is WireCallback
  """
  Real-world User-Agent strings can run 200-500 bytes (browser + OS +
  webview + extensions tacked on). We send a ~1 KB User-Agent — well
  below any sane per-header limit but bigger than typical — to verify
  the server accepts realistic UA sizes.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-10.1.5-02-long-user-agent"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String(1200)
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nUser-Agent: Mozilla/5.0 (")
      var i: USize = 0
      while i < 1000 do
        s.push('x')
        i = i + 1
      end
      s.append(")\r\nConnection: close\r\n\r\n")
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
          "GET with ~1KB User-Agent returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
