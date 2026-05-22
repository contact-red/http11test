use "net"
use "../wire"
use "../runner"

actor UriWithOnlyQuery is WireCallback
  """
  RFC 9112 §3.2.1: origin-form is `absolute-path [ "?" query ]`. An
  absolute-path must begin with `/`. Sending `?foo=bar` alone (no
  leading slash) is malformed. Server should respond 400.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-3.2.1-01-no-leading-slash"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET ?foo=bar HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 400) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "URI starting with '?' returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
