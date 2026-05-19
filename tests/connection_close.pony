use "net"
use "../wire"
use "../runner"

actor ConnectionCloseRunner is WireCallback
  """
  Covers rfc9112-9.6-05 (MUST NOT process further requests after receiving
  Connection: close) and by extension rfc9112-9.6-03 (server MUST initiate
  closure after sending the final response).

  We pipeline two HEAD requests in a single write. The first carries
  `Connection: close`; the second is plain. A compliant server processes
  request 1, sends response 1, closes — request 2 is never processed.
  We PASS if the byte stream ends after response 1's header terminator,
  FAIL if there's a valid second response in the buffer.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-9.6-05"

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
      s.append("\r\nConnection: close\r\n\r\n")
      s.append("HEAD / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\n\r\n")
      s
    end

    WireClient(auth, host, service, requests, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code < 200) or (code >= 300) then
        _reporter.fail(_test_id,
          "response 1 was " + code.string() + " (target should serve 2xx on /)")
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, "response 1: " + err.describe())
      return
    end

    match ResponseParser.body_offset(bytes)
    | let offset: USize =>
      // HEAD response has no body, so anything past the header terminator
      // is either response 2 (server processed it — FAIL) or nothing
      // (server closed properly — PASS).
      if offset >= bytes.size() then
        _reporter.pass(_test_id)
      else
        let after = bytes.trim(offset)
        match ResponseParser.status_code(after)
        | let _: U16 =>
          _reporter.fail(_test_id,
            "server processed the pipelined request after `Connection: close`")
        | let _: ParseError =>
          // Trailing garbage that isn't a valid response. Either the
          // server flushed something odd or our parser disagrees. Treat
          // as PASS: there's no second response to speak of.
          _reporter.pass(_test_id)
        end
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
