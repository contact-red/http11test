use "net"
use "../wire"
use "../runner"

actor PipelineOrder is WireCallback
  """
  Covers rfc9112-9.3.2-02: a server MAY process pipelined safe-method
  requests in parallel but MUST send their responses in the order the
  requests were received. We send two GET / requests in one write (no
  reads between them), then locate response 2 in the byte stream by
  walking past response 1's headers + Content-Length-worth of body bytes.
  PASS iff response 2 also parses as 2xx.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-9.3.2-02"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let requests = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\n\r\n")
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, requests, this)

  be on_response(bytes: Array[U8] val) =>
    // Verify response 1 status code.
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code < 200) or (code >= 300) then
        _reporter.fail(_test_id,
          "response 1 was " + code.string())
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, "response 1: " + err.describe())
      return
    end

    // Locate response 1's body end via headers + Content-Length.
    let r1_body_start = match ResponseParser.body_offset(bytes)
    | let n: USize => n
    | let err: ParseError =>
      _reporter.fail(_test_id, "response 1: " + err.describe())
      return
    end

    let r1_cl = match ResponseParser.content_length(bytes)
    | let n: USize => n
    | let err: ParseError =>
      _reporter.fail(_test_id,
        "response 1 missing Content-Length (test needs it to find response 2): "
          + err.describe())
      return
    end

    let r2_start = r1_body_start + r1_cl
    if r2_start >= bytes.size() then
      _reporter.fail(_test_id,
        "no bytes after response 1 — server did not return a second response")
      return
    end

    // Parse response 2's status.
    let r2_bytes = bytes.trim(r2_start)
    match ResponseParser.status_code(r2_bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "response 2 was " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id,
        "response 2: " + err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
