use "net"
use "../wire"
use "../runner"

actor GetWithQueryString is WireCallback
  """
  Browsers send query strings on most navigations. We verify that a GET
  with a query component on the request-target returns 2xx and doesn't
  trip over `?`, `=`, or `&` in the request-line.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-query-string"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /?foo=bar&baz=qux HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
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
          "GET /?foo=bar&baz=qux returned " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
