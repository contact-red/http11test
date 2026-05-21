use "net"
use "../wire"
use "../runner"

actor PersistentHeadThenGet is WireCallback
  """
  Pipelined HEAD followed by GET on the same connection. Both must
  receive proper responses in order, and the GET's response must be
  parseable immediately after the HEAD's `\\r\\n\\r\\n` (HEAD per RFC
  has no body, so no offset is needed beyond the header terminator).
  """
  let _reporter: Reporter
  let _test_id: String = "interop-persistent-head-then-get"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let requests = recover val
      let s = String
      s.append("HEAD / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\n\r\n")
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, requests, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 if (code < 200) or (code >= 300) =>
      _reporter.fail(_test_id, "HEAD response was " + code.string())
      return
    | let err: ParseError =>
      _reporter.fail(_test_id, "HEAD response: " + err.describe())
      return
    end

    // HEAD has no body per RFC, so response 2 begins immediately after
    // the HEAD's header-terminating CRLFCRLF.
    let r1_end = match ResponseParser.body_offset(bytes)
    | let n: USize => n
    | let err: ParseError =>
      _reporter.fail(_test_id, "HEAD body offset: " + err.describe())
      return
    end

    if r1_end >= bytes.size() then
      _reporter.fail(_test_id, "no second response after HEAD")
      return
    end

    let r2_bytes = bytes.trim(r1_end)
    match ResponseParser.status_code(r2_bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "GET (response 2) was " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, "GET (response 2): " + err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
