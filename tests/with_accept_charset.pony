use "net"
use "../wire"
use "../runner"

actor WithAcceptCharset is WireCallback
  """
  `Accept-Charset` is a deprecated header (RFC 9110 §12.5.2) but
  legacy clients still send it. Servers must not break.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-12.5.2-01-accept-charset"

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
      s.append("\r\nAccept-Charset: utf-8, iso-8859-1;q=0.5\r\n")
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
          "GET with Accept-Charset returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
