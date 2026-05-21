use "net"
use "../wire"
use "../runner"

actor HeaderValueWithEquals is WireCallback
  """
  `=` is a VCHAR (0x3D) and so legal in field-value. Many headers
  use it (Accept-Language, parameter=value pairs). Server must
  accept multiple `=` signs.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-header-value-equals"

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
      s.append("\r\nX-Token: a=b=c==dd=\r\n")
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
          "header value with `=` returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
