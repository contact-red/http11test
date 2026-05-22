use "net"
use "../wire"
use "../runner"

actor Http10KeepAlive is WireCallback
  """
  HTTP/1.0 defaults to `Connection: close`, but a client can request
  persistent behavior via `Connection: keep-alive`. Per RFC 9112 §9.1,
  servers SHOULD respect this and keep the connection open until a final
  `close` or timeout. We send 2 pipelined HTTP/1.0 requests with
  keep-alive and verify two responses.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-9.1-01-http10-keep-alive"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let requests = recover val
      let s = String
      s.append("GET / HTTP/1.0\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: keep-alive\r\n\r\n")
      s.append("GET / HTTP/1.0\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, requests, this)

  be on_response(bytes: Array[U8] val) =>
    // First response.
    match ResponseParser.status_code(bytes)
    | let code: U16 if (code < 200) or (code >= 300) =>
      _reporter.fail(_test_id, "response 1 was " + code.string())
      return
    | let err: ParseError =>
      _reporter.fail(_test_id, "response 1: " + err.describe())
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
    | let _: ParseError => 0
    end

    let r2_start = r1_body_start + r1_cl
    if r2_start >= bytes.size() then
      _reporter.fail(_test_id,
        "no second response — server closed after HTTP/1.0 + keep-alive")
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
