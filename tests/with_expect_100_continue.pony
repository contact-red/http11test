use "net"
use "../wire"
use "../runner"

actor WithExpect100Continue is WireCallback
  """
  `Expect: 100-continue` is only meaningful for requests with a body that
  the client wants the server to validate before sending. For a GET with
  no body, RFC 9110 §10.1.1 says servers may ignore it. We accept a
  final 2xx (Expect ignored) or 417 (Expect rejected) — both are
  documented behaviors.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-with-expect-100"

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
      s.append("\r\nExpect: 100-continue\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    // The response may begin with a 100-continue interim status; the
    // tolerant parser will read the first status line it sees. We need to
    // locate the FINAL status — i.e., skip any 1xx interim status.
    match _final_status(bytes)
    | let code: U16 =>
      if ((code >= 200) and (code < 300)) or (code == 417) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "GET with Expect: 100-continue returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  fun _final_status(bytes: Array[U8] val): (U16 | ParseError) =>
    // If the first status is 1xx, find the next CRLF CRLF and recurse
    // into the remainder.
    match ResponseParser.status_code(bytes)
    | let code: U16 if (code >= 100) and (code < 200) =>
      match ResponseParser.body_offset(bytes)
      | let off: USize =>
        let rest = recover val bytes.trim(off) end
        if rest.size() == 0 then code else _final_status(rest) end
      | let err: ParseError => err
      end
    | let code: U16 => code
    | let err: ParseError => err
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
