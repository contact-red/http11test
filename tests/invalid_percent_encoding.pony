use "net"
use "../wire"
use "../runner"

actor InvalidPercentEncoding is WireCallback
  """
  RFC 3986 §2.1: `pct-encoded = "%" HEXDIG HEXDIG`. `%ZZ` and `%XY` are
  not valid percent-encodings. A strict server returns 400; a lenient
  one may treat as opaque bytes. We accept any non-2xx OR 200 (lenient).
  """
  let _reporter: Reporter
  let _test_id: String = "interop-invalid-percent-encoding"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /path%ZZencoded HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "invalid %-encoding returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
