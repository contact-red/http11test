use "net"
use "../wire"
use "../runner"

actor HeaderNameMixedCase is WireCallback
  """
  RFC 9110 §5.1: field-name is case-insensitive. Bizarre case mixes
  like `cONnEcTiOn: close` are still valid and the server must
  recognize them.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.1-02-header-mixed-case"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHoSt: ")
      s.append(host)
      s.append("\r\ncONnEcTiOn: close\r\n\r\n")
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
          "mixed-case header names returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
