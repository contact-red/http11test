use "net"
use "../wire"
use "../runner"

actor GetHugeHostName is WireCallback
  """
  Host name approaching the FQDN length limit (~253 chars per RFC
  1035). We send a 200-character host name. Server may accept or
  reject as too-long.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.2.2-21-huge-host-name"

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
      var i: USize = 0
      while i < 200 do
        s.append("a")
        i = i + 1
      end
      s.append(".com\r\nConnection: close\r\n\r\n")
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
          "huge host name returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
