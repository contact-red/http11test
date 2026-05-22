use "net"
use "../wire"
use "../runner"

actor PostHeadPipeline is WireCallback
  """
  Pipelined POST (with body) followed by HEAD. Probes the server's
  ability to advance past a Content-Length-framed body AND then
  correctly suppress the HEAD response body (per RFC 9110 §9.3.2).
  """
  let _reporter: Reporter
  let _test_id: String = "interop-post-head-pipeline"

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
      s.append("HEAD / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, requests, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 if (code < 200) or (code >= 500) =>
      _reporter.fail(_test_id, "POST response was " + code.string())
      return
    | let err: ParseError =>
      _reporter.fail(_test_id, "POST response: " + err.describe())
      return
    end

    let r1_body_start = match ResponseParser.body_offset(bytes)
    | let n: USize => n
    | let err: ParseError =>
      _reporter.fail(_test_id, "POST body offset: " + err.describe())
      return
    end

    let r1_cl = match ResponseParser.content_length(bytes)
    | let n: USize => n
    | let _: ParseError => 0
    end

    let r2_start = r1_body_start + r1_cl
    if r2_start >= bytes.size() then
      _reporter.fail(_test_id, "no HEAD response after POST")
      return
    end

    let r2_bytes = bytes.trim(r2_start)
    match ResponseParser.status_code(r2_bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id, "HEAD response was " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, "HEAD response: " + err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
