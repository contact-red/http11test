use "net"
use "../wire"
use "../runner"

actor HeaderFieldNameWithUnderscore is WireCallback
  """
  `_` is a tchar per RFC 9110 §5.6.2. Headers like `X_FORWARDED_FOR`
  show up from PHP/CGI environments. Server must accept.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.6.2-06-underscore-field-name"

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
      s.append("\r\nX_Forwarded_For: 10.0.0.1\r\n")
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
          "header name with underscore returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
