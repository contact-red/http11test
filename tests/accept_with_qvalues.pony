use "net"
use "../wire"
use "../runner"

actor AcceptWithQvalues is WireCallback
  """
  RFC 9110 §12.5.1: Accept supports q-values for preference ordering.
  `Accept: text/plain;q=0.5, text/html;q=0.9` is typical browser
  output. Server must accept.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-12.5.1-05-qvalues"

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
      s.append("\r\nAccept: text/plain;q=0.5, text/html;q=0.9, */*;q=0.1\r\n")
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
          "Accept with q-values returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
