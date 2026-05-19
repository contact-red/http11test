use "net"
use "../wire"
use "../runner"

actor NoObsFoldInResponse is WireCallback
  """
  Covers rfc9112-5.2-01 (MUST NOT): a sender MUST NOT generate a message
  that includes line folding (obs-fold). We scan the server's response
  header section for any CRLF followed by SP or HTAB — the obs-fold
  pattern — and FAIL if any is found.

  Property test: verifies the server's emit-side compliance, not its
  parser. Even servers that ACCEPT obs-fold on input (Apache, Caddy,
  Bandit, lighttpd from wave 1) should never PRODUCE it.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-5.2-01"

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
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code < 200) or (code >= 300) then
        _reporter.fail(_test_id, "GET / returned " + code.string())
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    let body_start = match ResponseParser.body_offset(bytes)
    | let n: USize => n
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    try
      var i: USize = 0
      while (i + 2) < body_start do
        if (bytes(i)? == '\r') and (bytes(i + 1)? == '\n') then
          let next = bytes(i + 2)?
          if (next == ' ') or (next == '\t') then
            _reporter.fail(_test_id,
              "obs-fold detected at byte offset " + i.string())
            return
          end
        end
        i = i + 1
      end
      _reporter.pass(_test_id)
    else
      _reporter.fail(_test_id, "bounds error scanning header section")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
