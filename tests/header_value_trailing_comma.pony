use "net"
use "../wire"
use "../runner"

actor HeaderValueTrailingComma is WireCallback
  """
  RFC 9110 §5.6.1: list elements may have empty members
  (`1#element`). A trailing comma like `Accept-Encoding: gzip,`
  signals an empty list element, which is allowed but unusual.
  Server should accept.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.6.1-02-trailing-comma"

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
      s.append("\r\nAccept-Encoding: gzip,\r\n")
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
          "trailing comma in list returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
