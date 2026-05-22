use "net"
use "../wire"
use "../runner"

actor AcceptStarAlone is WireCallback
  """
  RFC 9110 §12.5.1: Accept values follow media-type grammar:
  `type/subtype`. A bare `*` (no `/`) is malformed. Strict servers
  may reject; lenient servers may treat as `*/*`.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-12.5.1-02-star-alone"

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
      s.append("\r\nAccept: *\r\n")
      s.append("Connection: close\r\n\r\n")
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
          "Accept: * returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
