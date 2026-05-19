use "net"
use "../wire"
use "../runner"

actor ThreePersistentHeads is WireCallback
  """
  Extends rfc9112-9.3-01: a real browser page load opens one keep-alive
  connection and pumps 3-6 requests through it. We pipeline three HEAD
  requests (last with Connection: close) and count the CRLF CRLF
  response terminators. PASS iff we see three.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-9.3-01-three"

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
      s.append("HEAD / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\n\r\n")
      s.append("HEAD / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, requests, this)

  be on_response(bytes: Array[U8] val) =>
    var count: USize = 0
    try
      var i: USize = 0
      while (i + 3) < bytes.size() do
        if (bytes(i)? == '\r')
          and (bytes(i + 1)? == '\n')
          and (bytes(i + 2)? == '\r')
          and (bytes(i + 3)? == '\n')
        then
          count = count + 1
          i = i + 4
        else
          i = i + 1
        end
      end
    end
    if count >= 3 then
      _reporter.pass(_test_id)
    else
      _reporter.fail(_test_id,
        "expected 3 pipelined HEAD responses; found "
          + count.string() + " CRLF CRLF terminators")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
