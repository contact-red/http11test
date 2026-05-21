use "net"
use "../wire"
use "../runner"

actor HttpLowercaseName is WireCallback
  """
  RFC 9112 §2.5: HTTP-name is the literal `HTTP` — uppercase only.
  `http/1.1` (lowercase) is malformed. Server should respond 400.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-2.5-02-lowercase-http-name"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / http/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 400) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "lowercase 'http/1.1' returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
