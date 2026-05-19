use "net"
use "../wire"
use "../runner"

actor BrowserStyleRequest is WireCallback
  """
  Sanity check that a request resembling what an actual browser sends —
  with User-Agent, Accept, Accept-Encoding, Accept-Language — is handled
  normally. No specific RFC test ID; this guards against servers that
  choke on plausible real-world headers (e.g. via too-aggressive header
  validation that rejects common values).
  """
  let _reporter: Reporter
  let _test_id: String = "interop-browser-style"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\n")
      s.append("Host: ")
      s.append(host)
      s.append("\r\n")
      s.append("User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36\r\n")
      s.append("Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n")
      s.append("Accept-Encoding: gzip, deflate, br\r\n")
      s.append("Accept-Language: en-US,en;q=0.5\r\n")
      s.append("Connection: close\r\n\r\n")
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
          "browser-style GET / returned " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
