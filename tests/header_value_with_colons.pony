use "net"
use "../wire"
use "../runner"

actor HeaderValueWithColons is WireCallback
  """
  RFC 9110 §5.5: value with colons

  Header values may contain colons (Date timestamps, ratios, URIs all
  use them). The parser must split on the FIRST `:` only — everything
  after the first colon is part of the value.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.5-08-value-with-colons"

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
      s.append("\r\nX-Time: 12:34:56\r\n")
      s.append("X-Url: https://example.com:8080/path\r\n")
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
          "colons in header value returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
