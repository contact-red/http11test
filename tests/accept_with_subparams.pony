use "net"
use "../wire"
use "../runner"

actor AcceptWithSubparams is WireCallback
  """
  RFC 9110 §12.5.1: Accept media-type may carry params beyond q:
  `Accept: text/html;q=0.9;level=2;charset=utf-8`. Server must
  accept the parameter list.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-accept-subparams"

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
      s.append("\r\nAccept: text/html;q=0.9;level=2;charset=utf-8\r\n")
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
          "Accept with sub-params returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
