use "net"
use "../wire"
use "../runner"

actor IdnHost is WireCallback
  """
  Internationalized domain names arrive over the wire in punycode/A-label
  form (RFC 5891), looking like `xn--80akhbyknj4f.xn--p1ai`. Server
  must accept the ASCII representation in Host.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-idn-host"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: xn--80akhbyknj4f.xn--p1ai\r\n")
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
          "IDN host returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
