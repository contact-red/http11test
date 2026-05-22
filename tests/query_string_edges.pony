use "net"
use "../wire"
use "../runner"

actor QueryStringEdges is WireCallback
  """
  Edge cases in query string syntax: leading `&`, trailing `&`,
  `?=` (empty key empty value), key with no `=`. All are valid
  application-defined query strings; server must pass through.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-query-string-edges"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /?&a=1&&b=&=val&c HTTP/1.1\r\nHost: ")
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
          "edge-case query returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
