use "net"
use "time"

actor WireClient
  """
  Opens one TCP connection, sends one request, accumulates the response
  bytes, and delivers exactly one outcome to the callback: either
  `on_response(bytes)` when the server closes the connection, or
  `on_error(reason)` when something goes wrong (connect failure, hard
  timeout).

  The per-test timeout is the load-bearing guarantee here. Without it,
  a server that doesn't respond (because it's waiting for chunk data
  that won't arrive, or because the parser entered an unrecoverable
  state) would keep the actor alive indefinitely and stall the whole
  suite. The timeout disposes the connection, marks the test failed,
  and lets the suite move on.
  """
  let _callback: WireCallback
  let _timers: Timers = Timers
  var _conn: (TCPConnection tag | None) = None
  var _buf: Array[U8] iso = recover Array[U8] end
  var _completed: Bool = false

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    request: ByteSeq,
    callback: WireCallback,
    timeout_ns: U64 = 15_000_000_000)  // 15 seconds default
  =>
    _callback = callback
    let notify: _WireNotify iso = _WireNotify(this, request)
    _conn = TCPConnection(auth, consume notify, host, service)
    let timer = Timer(_TimeoutNotify(this), timeout_ns)
    _timers(consume timer)

  be _on_data(bytes: Array[U8] iso) =>
    if _completed then return end
    _buf.append(consume bytes)

  be _on_closed() =>
    if _completed then return end
    _completed = true
    let snapshot: Array[U8] iso = _buf = recover Array[U8] end
    _callback.on_response(consume snapshot)

  be _on_connect_failed() =>
    if _completed then return end
    _completed = true
    _callback.on_error("connect_failed")

  be _on_timeout() =>
    if _completed then return end
    _completed = true
    match _conn
    | let c: TCPConnection tag => c.dispose()
    end
    _callback.on_error("test timed out")
