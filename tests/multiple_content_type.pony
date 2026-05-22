use "net"
use "../wire"
use "../runner"

actor MultipleContentType is WireCallback
  """
  RFC 9110 §5.3: Content-Type is a singleton field, not a list.
  Multiple Content-Type headers are malformed. Strict servers reject.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-8.3-02-multiple-content-type"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("POST / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nContent-Type: text/plain\r\n")
      s.append("Content-Type: application/json\r\n")
      s.append("Content-Length: 0\r\n")
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
          "multiple Content-Type returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
