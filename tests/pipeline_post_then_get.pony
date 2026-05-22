use "net"
use "../wire"
use "../runner"

actor PipelinePostThenGet is WireCallback
  """
  Pipelined POST (with body) followed by GET in the same TCP write.
  Probes the server's ability to advance past a Content-Length-framed
  body before parsing the next request. A naive parser that reads to
  CRLFCRLF and then expects the next request might misframe and reply
  with 400 to the GET.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-9.3-04-post-then-get"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let requests = recover val
      let s = String
      s.append("POST / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nContent-Length: 5\r\n\r\nhello")
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, requests, this)

  be on_response(bytes: Array[U8] val) =>
    // Verify response 1 was successful.
    let r1_code: U16 = match ResponseParser.status_code(bytes)
    | let code: U16 => code
    | let err: ParseError =>
      _reporter.fail(_test_id, "response 1: " + err.describe())
      return
    end
    if (r1_code < 200) or (r1_code >= 600) or (r1_code == 500) then
      _reporter.fail(_test_id, "response 1 was " + r1_code.string())
      return
    end

    let r1_body_start = match ResponseParser.body_offset(bytes)
    | let n: USize => n
    | let err: ParseError =>
      _reporter.fail(_test_id, "response 1 body: " + err.describe())
      return
    end

    let r1_cl = match ResponseParser.content_length(bytes)
    | let n: USize => n
    | let _: ParseError => 0  // some servers omit CL; assume zero body
    end

    let r2_start = r1_body_start + r1_cl
    if r2_start >= bytes.size() then
      _reporter.fail(_test_id,
        "no second response — pipelined GET was not handled")
      return
    end

    let r2_bytes = bytes.trim(r2_start)
    match ResponseParser.status_code(r2_bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id, "response 2 was " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, "response 2: " + err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
