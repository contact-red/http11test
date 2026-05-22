use "net"
use "../wire"
use "../runner"

actor Http10Request is WireCallback
  """
  RFC 9112 §2.5: http10 request

  HTTP/1.0 clients still exist (curl --http1.0, embedded devices, some
  command-line tools). Server must accept HTTP/1.0 requests and
  respond. HTTP/1.0 default is no keep-alive, so the connection closes
  naturally — perfect for our wire harness.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-2.5-03-http10-request"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.0\r\nHost: ")
      s.append(host)
      s.append("\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "GET HTTP/1.0 returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
