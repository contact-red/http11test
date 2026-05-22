use "net"
use "../wire"
use "../runner"

actor ResponseStartsWithHttp11 is WireCallback
  """
  RFC 9112 §4: status-line = HTTP-version SP status-code SP reason
  phrase CRLF. The first 8 bytes of the response MUST be `HTTP/1.x`
  where x is 0 or 1. This sanity-check guards against servers that
  emit garbage / interleave debug output / send HTTP/2 framing on
  an HTTP/1.1 connection.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-4-05-status-line-prefix"

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
    if bytes.size() < 8 then
      _reporter.fail(_test_id, "response too short")
      return
    end
    try
      let prefix = String.from_iso_array(recover bytes.trim(0, 7).clone() end)
      if (prefix == "HTTP/1.") and
        ((bytes(7)? == '0') or (bytes(7)? == '1'))
      then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "response prefix is not HTTP/1.x: " + consume prefix)
      end
    else
      _reporter.fail(_test_id, "could not inspect response prefix")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
