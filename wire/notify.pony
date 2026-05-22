use "net"
use "time"

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
  Adapter that forwards lori/net callbacks back to the owning
  WireClient actor as async behaviors. State (buffer, completion flag)
  lives in the actor so the timeout race is decided in one place.
  """
  let _client: WireClient
  let _request: ByteSeq

  new iso create(client: WireClient, request: ByteSeq) =>
    _client = client
    _request = request

  fun ref connected(conn: TCPConnection ref) =>
    conn.write(_request)

  fun ref connect_failed(conn: TCPConnection ref) =>
    _client._on_connect_failed()

  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize)
    : Bool
  =>
    _client._on_data(consume data)
    true

  fun ref closed(conn: TCPConnection ref) =>
    _client._on_closed()

class _TimeoutNotify is TimerNotify
  """
  One-shot timer that delivers the per-test timeout to WireClient.
  """
  let _client: WireClient

  new iso create(client: WireClient) =>
    _client = client

  fun ref apply(timer: Timer, count: U64): Bool =>
    _client._on_timeout()
    false
