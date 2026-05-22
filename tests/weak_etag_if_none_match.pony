use "net"
use "../wire"
use "../runner"

actor WeakEtagIfNoneMatch is WireCallback
  """
  RFC 9110 §8.8.3: weak ETags prefixed with `W/` are part of the
  vocabulary. `If-None-Match: W/"abc"` is valid. Server should
  process or ignore but not error.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-weak-etag-if-none-match"

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
      s.append("\r\nIf-None-Match: W/\"abc123\"\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code == 200) or (code == 304) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "weak ETag conditional returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
