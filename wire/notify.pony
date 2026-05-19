use "net"

interface tag WireCallback
  """
  Implemented by anything that wants to drive a single HTTP request over a raw
  TCP connection and react to the resulting bytes (or to a connection error).
  Both behaviors are called exactly once per WireClient session.
  """
  be on_response(bytes: Array[U8] val)
  be on_error(reason: String)

class _WireNotify is TCPConnectionNotify
  """
  Drives one HTTP request: writes the request bytes on `connected`, accumulates
  every byte the server sends in `received`, and hands the snapshot to the
  callback on `closed`. Treats connect failure and unexpected close-before-data
  as error conditions.
  """
  let _callback: WireCallback
  let _request: ByteSeq
  var _buf: Array[U8] iso

  new iso create(callback: WireCallback, request: ByteSeq) =>
    _callback = callback
    _request = request
    _buf = recover Array[U8] end

  fun ref connected(conn: TCPConnection ref) =>
    conn.write(_request)

  fun ref connect_failed(conn: TCPConnection ref) =>
    _callback.on_error("connect_failed")

  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize)
    : Bool
  =>
    _buf.append(consume data)
    true

  fun ref closed(conn: TCPConnection ref) =>
    let snapshot = _buf = recover Array[U8] end
    _callback.on_response(consume snapshot)
