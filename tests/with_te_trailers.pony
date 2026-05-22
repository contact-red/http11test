use "net"
use "../wire"
use "../runner"

actor WithTeTrailers is WireCallback
  """
  `TE: trailers` advertises the client's willingness to receive trailers
  in a chunked response (RFC 9110 §10.1.4). On a GET with no body this
  is a hint only — server must accept and respond normally.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-10.1.4-01-te-trailers"

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
      s.append("\r\nTE: trailers\r\n")
      s.append("Connection: close\r\n\r\n")
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
          "GET with TE: trailers returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
