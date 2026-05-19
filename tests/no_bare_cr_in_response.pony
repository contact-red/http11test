use "net"
use "../wire"
use "../runner"

actor NoBareCrInResponse is WireCallback
  """
  Covers rfc9112-2.2-03 (MUST NOT): a sender MUST NOT generate a bare CR
  (a CR not immediately followed by LF) within any protocol elements
  other than the content. We scan the entire header section + status line
  of the response (everything up to body_offset) and FAIL if any CR
  isn't immediately followed by LF.

  Bare CR in protocol elements is a known request-smuggling vector and
  RFC 9112 makes this MUST NOT for senders for that reason.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-2.2-03"

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
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code < 200) or (code >= 300) then
        _reporter.fail(_test_id, "GET / returned " + code.string())
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    let body_start = match ResponseParser.body_offset(bytes)
    | let n: USize => n
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    try
      var i: USize = 0
      while i < body_start do
        if bytes(i)? == '\r' then
          let is_followed_by_lf =
            ((i + 1) < body_start) and (bytes(i + 1)? == '\n')
          if not is_followed_by_lf then
            _reporter.fail(_test_id,
              "bare CR detected at byte offset " + i.string())
            return
          end
        end
        i = i + 1
      end
      _reporter.pass(_test_id)
    else
      _reporter.fail(_test_id, "bounds error scanning header section")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
