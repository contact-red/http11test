use "net"
use "../wire"
use "../runner"

interface tag _PersistentCallback
  """
  Internal callback from _PersistentNotify back to the test actor. The
  notifier hands off the accumulated bytes plus the byte offset that
  delimits the first response, plus the final state (so the actor can
  tell whether request 2 was ever sent).
  """
  be on_persistent_response(
    bytes: Array[U8] val,
    resp1_end: USize,
    state: U8)
  be on_persistent_error(reason: String)


class _PersistentNotify is TCPConnectionNotify
  """
  Two-phase notifier: send request 1 on connect, watch incoming bytes for
  the CRLF CRLF terminator of response 1, send request 2 immediately, let
  the server close after, then hand the accumulated buffer back.
  """
  let _callback: _PersistentCallback
  let _request1: ByteSeq
  let _request2: ByteSeq
  var _buf: Array[U8] iso
  var _state: U8 = 0
  var _resp1_end: USize = 0

  new iso create(
    callback: _PersistentCallback,
    request1: ByteSeq,
    request2: ByteSeq)
  =>
    _callback = callback
    _request1 = request1
    _request2 = request2
    _buf = recover Array[U8] end

  fun ref connected(conn: TCPConnection ref) =>
    conn.write(_request1)

  fun ref connect_failed(conn: TCPConnection ref) =>
    _callback.on_persistent_error("connect_failed")

  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize)
    : Bool
  =>
    _buf.append(consume data)
    if _state == 0 then
      match _find_crlf_crlf(0)
      | let pos: USize =>
        _resp1_end = pos
        _state = 1
        conn.write(_request2)
      end
    end
    true

  fun ref _find_crlf_crlf(start: USize): (USize | None) =>
    var i: USize = start
    while (i + 3) < _buf.size() do
      try
        if (_buf(i)? == '\r')
          and (_buf(i + 1)? == '\n')
          and (_buf(i + 2)? == '\r')
          and (_buf(i + 3)? == '\n')
        then
          return i + 4
        end
      end
      i = i + 1
    end
    None

  fun ref closed(conn: TCPConnection ref) =>
    let snapshot = _buf = recover Array[U8] end
    _callback.on_persistent_response(consume snapshot, _resp1_end, _state)


actor PersistentConnectionRunner is _PersistentCallback
  """
  Covers rfc9112-9.3-01: HTTP implementations SHOULD support persistent
  connections. We send HEAD / as request 1 (implicit keep-alive), wait
  for the CRLF CRLF terminator, then send GET / with Connection: close as
  request 2 on the same socket. PASS iff both responses are 2xx and
  appear in the same byte stream.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-9.3-01"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request1 = recover val
      let s = String
      s.append("HEAD / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\n\r\n")
      s
    end

    let request2 = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    TCPConnection(
      auth,
      _PersistentNotify(this, request1, request2),
      host, service)

  be on_persistent_response(
    bytes: Array[U8] val,
    resp1_end: USize,
    state: U8)
  =>
    if state == 0 then
      _reporter.fail(_test_id,
        "no end-of-headers found in response 1; server may have closed mid-headers")
      return
    end

    let resp1: Array[U8] val = bytes.trim(0, resp1_end)
    match ResponseParser.status_code(resp1)
    | let code: U16 =>
      if (code < 200) or (code >= 300) then
        _reporter.fail(_test_id,
          "HEAD response 1 was " + code.string() + " (target should serve 2xx on /)")
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id,
        "response 1: " + err.describe())
      return
    end

    if resp1_end >= bytes.size() then
      _reporter.fail(_test_id,
        "connection closed after response 1 — server does not appear to support persistent connections")
      return
    end

    let resp2: Array[U8] val = bytes.trim(resp1_end)
    match ResponseParser.status_code(resp2)
    | let code: U16 =>
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "GET response 2 was " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id,
        "response 2: " + err.describe())
    end

  be on_persistent_error(reason: String) =>
    _reporter.fail(_test_id, reason)
