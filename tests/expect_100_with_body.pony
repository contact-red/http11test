use "net"
use "../wire"
use "../runner"

actor Expect100WithBody is WireCallback
  """
  RFC 9110 §10.1.1: when a request includes `Expect: 100-continue` AND
  has a body, an origin server SHOULD send a 100 (Continue) interim
  response before reading the body — if it intends to accept the
  request. This is a finding, not a hard rejection: we count whether a
  100 was emitted ahead of the final status. PASS regardless (since the
  SHOULD is qualified by "if willing"), but the parse trail shows
  divergence.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-expect-100-with-body"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("POST / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nContent-Length: 5\r\n")
      s.append("Expect: 100-continue\r\n")
      s.append("Connection: close\r\n\r\nhello")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    // Read the first status. If it's 100, skip past and read the final.
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 100) and (code < 200) then
        // 100 Continue interim — find the next response after CRLFCRLF.
        match ResponseParser.body_offset(bytes)
        | let off: USize =>
          let rest = recover val bytes.trim(off) end
          match ResponseParser.status_code(rest)
          | let final: U16 =>
            if (final >= 200) and (final < 600) and (final != 500) then
              _reporter.pass(_test_id)
            else
              _reporter.fail(_test_id,
                "after 100, final was " + final.string())
            end
          | let err: ParseError =>
            _reporter.fail(_test_id, "after 100: " + err.describe())
          end
        | let err: ParseError => _reporter.fail(_test_id, err.describe())
        end
      elseif (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id, "POST returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
