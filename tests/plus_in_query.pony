use "net"
use "../wire"
use "../runner"

actor PlusInQuery is WireCallback
  """
  RFC 3986 §3.4: plus in query

  `+` is historically used as space encoding in query strings (form-
  urlencoded). Servers must accept `+` in the query component without
  rejecting the request.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.4-05-plus-in-query"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /?q=hello+world&n=42 HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "GET with `+` in query returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
