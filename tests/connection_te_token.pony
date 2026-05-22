use "net"
use "../wire"
use "../runner"

actor ConnectionTeToken is WireCallback
  """
  RFC 9110 §7.6.1: `TE` is a hop-by-hop header and is listed in the
  Connection header to indicate so. Sending `Connection: TE, close`
  is a real-world shape from proxies — server must close and respond.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-7.6.1-05-te-token"

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
      s.append("Connection: TE, close\r\n\r\n")
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
          "Connection: TE, close returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
