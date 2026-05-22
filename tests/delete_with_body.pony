use "net"
use "../wire"
use "../runner"

actor DeleteWithBody is WireCallback
  """
  DELETE with a body. RFC 9110 §9.3.5: a payload within DELETE has
  no defined semantics, but server must consume the body to keep
  framing consistent for the next request on the connection.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.3.5-02-delete-with-body"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("DELETE /resource HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nContent-Length: 11\r\n")
      s.append("Connection: close\r\n\r\nhello world")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "DELETE with body returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
