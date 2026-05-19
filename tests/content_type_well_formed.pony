use "net"
use "../wire"
use "../runner"

actor ContentTypeWellFormed is WireCallback
  """
  When a server emits Content-Type, its value must structurally match
  `type/subtype[; params]` (RFC 9110 §8.3). Server that emits a
  Content-Type that doesn't parse causes browsers to fall back to
  content-sniffing or refuse to render.

  We SKIP if the response has no Content-Type (hyper's bare handler
  case) — that's a different requirement, not this one.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-8.3-01-form"

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
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code < 200) or (code >= 300) then
        _reporter.fail(_test_id,
          "GET / returned " + code.string())
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    match ResponseParser.find_header_value(bytes, "content-type")
    | let value: String =>
      if MediaType.is_valid(value) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "Content-Type value \"" + value + "\" does not parse as media-type")
      end
    | None =>
      _reporter.skip(_test_id, "response has no Content-Type to validate")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
