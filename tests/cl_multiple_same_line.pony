use "net"
use "../wire"
use "../runner"

actor ClMultipleSameLine is WireCallback
  """
  RFC 9110 §8.6: a Content-Length value containing a comma-separated
  list of identical values is permitted to be normalized, BUT differing
  values are a framing error. We send `Content-Length: 5, 5` — two
  identical values on the same line. A strict server may reject; a
  lenient one accepts and treats as 5.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-cl-list-same-value"

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
      s.append("\r\nContent-Length: 5, 5\r\n")
      s.append("Connection: close\r\n\r\nhello")
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
          "CL: 5, 5 returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
