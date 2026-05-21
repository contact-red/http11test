use "net"
use "../wire"
use "../runner"

actor AcceptZeroQvalue is WireCallback
  """
  RFC 9110 §12.5.1: `Accept: ...;q=0` means the client explicitly
  rejects that media type. If the server has nothing else acceptable,
  it should return 406 Not Acceptable; otherwise it can return any
  alternative. For a server that always returns text/plain, the
  combination `Accept: text/plain;q=0, text/html` is contradictory —
  we accept any non-5xx response.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-accept-zero-qvalue"

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
      s.append("\r\nAccept: text/plain;q=0, text/html\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "Accept zero-q returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
