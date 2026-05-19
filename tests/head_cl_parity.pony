use "net"
use "../wire"
use "../runner"

actor HeadClParity is WireCallback
  """
  Covers rfc9110-8.6-03 (MUST NOT): a server MAY send Content-Length in a
  HEAD response, but MUST NOT send a value that differs from what the
  equivalent GET would have sent. We pipeline HEAD then GET on one
  connection, parse Content-Length from each, and FAIL if they're both
  present but unequal. HEAD with no Content-Length is allowed (PASS).

  Broken HEAD CL is a browser cache-invalidation hazard: caches use
  HEAD's headers to decide whether a cached resource is still fresh.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-8.6-03"

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
    // Response 1 = HEAD response. Verify it's 2xx, then locate its end.
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code < 200) or (code >= 300) then
        _reporter.fail(_test_id, "HEAD response was " + code.string())
        return
      end
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

    // HEAD has no body, so r1_end is also where response 2 starts.
    let r1_bytes = bytes.trim(0, r1_end)
    let r1_cl: (USize | None) = match ResponseParser.content_length(r1_bytes)
    | let n: USize => n
    | let _: ParseError => None
    end

    let r2_bytes = bytes.trim(r1_end)

    // Response 2 = GET response. Must be 2xx and have a Content-Length so
    // we have something to compare against.
    match ResponseParser.status_code(r2_bytes)
    | let code: U16 =>
      if (code < 200) or (code >= 300) then
        _reporter.fail(_test_id, "GET response was " + code.string())
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, "GET response: " + err.describe())
      return
    end

    match ResponseParser.content_length(r2_bytes)
    | let r2_value: USize =>
      match r1_cl
      | let r1_value: USize =>
        if r1_value == r2_value then
          _reporter.pass(_test_id)
        else
          _reporter.fail(_test_id,
            "HEAD Content-Length was " + r1_value.string()
              + " but GET Content-Length was " + r2_value.string())
        end
      | None =>
        // HEAD omitted Content-Length, which is allowed per the MAY half.
        _reporter.pass(_test_id)
      end
    | let err: ParseError =>
      _reporter.fail(_test_id,
        "GET response has no parseable Content-Length: " + err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
