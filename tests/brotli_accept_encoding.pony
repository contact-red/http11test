use "net"
use "../wire"
use "../runner"

actor BrotliAcceptEncoding is WireCallback
  """
  RFC 9110 §12.5.3: brotli

  `Accept-Encoding: br` — Brotli is the modern third coding (after
  gzip and deflate) supported by all major browsers since 2017.
  Server must accept the header; whether it actually serves br is
  optional (identity fallback is fine).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-12.5.3-02-brotli"

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
      s.append("\r\nAccept-Encoding: br, gzip, deflate\r\n")
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
          "Accept-Encoding: br returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
