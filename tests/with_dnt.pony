use "net"
use "../wire"
use "../runner"

actor WithDnt is WireCallback
  """
  RFC 9110 §5.3: dnt header

  `DNT: 1` ("Do Not Track") was sent by browsers for years. Now
  largely deprecated, but legacy clients still emit it. Server must
  not break.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.3-02-dnt-header"

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
      s.append("\r\nDNT: 1\r\n")
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
        _reporter.fail(_test_id, "GET with DNT returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
