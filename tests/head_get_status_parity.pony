use "net"
use "../wire"
use "../runner"

actor HeadGetStatusParity is WireCallback
  """
  RFC 9110 §9.3.2: status

  Covers rfc9110-9.3.2-02 (SHOULD) on the status-code axis: HEAD must
  return the same status code as GET would for the same resource.
  Browsers use HEAD for cache probes — if HEAD returns 404 but GET
  returns 200, the cache state diverges from reality.

  We pipeline HEAD then GET on one connection, parse both status codes,
  PASS iff they match.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.3.2-02-status"

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
    // HEAD = response 1; locate its end via body_offset (no body for HEAD).
    let head_code = match ResponseParser.status_code(bytes)
    | let c: U16 => c
    | let err: ParseError =>
      _reporter.fail(_test_id, "HEAD response: " + err.describe())
      return
    end

    let r1_end = match ResponseParser.body_offset(bytes)
    | let n: USize => n
    | let err: ParseError =>
      _reporter.fail(_test_id, "HEAD response: " + err.describe())
      return
    end

    if r1_end >= bytes.size() then
      _reporter.fail(_test_id, "no GET response — connection closed after HEAD")
      return
    end

    let r2_bytes = bytes.trim(r1_end)
    let get_code = match ResponseParser.status_code(r2_bytes)
    | let c: U16 => c
    | let err: ParseError =>
      _reporter.fail(_test_id, "GET response: " + err.describe())
      return
    end

    if head_code == get_code then
      _reporter.pass(_test_id)
    else
      _reporter.fail(_test_id,
        "HEAD returned " + head_code.string()
          + " but GET returned " + get_code.string())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
