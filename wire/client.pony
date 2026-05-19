use "net"

primitive WireClient
  """
  Entry point for opening one TCP connection, sending one request, and routing
  the response back to a callback. Future TLS support will sit behind a sibling
  constructor.
  """
  fun apply(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    request: ByteSeq,
    callback: WireCallback)
  =>
    TCPConnection(auth, _WireNotify(callback, request), host, service)
