use "net"
use "../wire"
use "../runner"

actor MinimalRequest is WireCallback
  """
  RFC 9112 §2: minimal request

  Smallest legal HTTP/1.1 request: GET / HTTP/1.1 + Host + CRLF CRLF.
  We add Connection: close so we can detect end-of-response by EOF.
  This is the bare-minimum probe — if this fails, something fundamental
  is broken.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-2-01-minimal-request"

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
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id, "minimal GET returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
