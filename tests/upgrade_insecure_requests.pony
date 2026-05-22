use "net"
use "../wire"
use "../runner"

actor UpgradeInsecureRequests is WireCallback
  """
  Modern browsers send `Upgrade-Insecure-Requests: 1` as a hint that
  they prefer HTTPS variants of the resource. Servers without an HTTPS
  upgrade path just ignore it.
  """
  let _reporter: Reporter
  let _test_id: String = "upgrade-insecure-requests-3-01"

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
      s.append("\r\nUpgrade-Insecure-Requests: 1\r\n")
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
          "GET with Upgrade-Insecure-Requests returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
