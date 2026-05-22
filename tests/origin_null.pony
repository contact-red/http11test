use "net"
use "../wire"
use "../runner"

actor OriginNull is WireCallback
  """
  RFC 6454 §7: origin null

  `Origin: null` is sent by browsers for sandboxed iframes,
  file:// pages, and certain privacy modes. Server must accept the
  literal string `null` without crashing.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc6454-7-02-origin-null"

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
      s.append("\r\nOrigin: null\r\n")
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
          "Origin: null returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
