use "net"
use "../wire"
use "../runner"

actor IfModifiedSinceFuture is WireCallback
  """
  An If-Modified-Since date in the future is malformed-by-context but
  must not crash the server. Per RFC 9110 §13.1.3, a future date is
  treated as "the resource has not been modified since then" → 304;
  many implementations ignore future dates and return 200. Either is
  acceptable.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-13.1.3-04-ims-future"

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
      s.append("\r\nIf-Modified-Since: Mon, 01 Jan 2099 00:00:00 GMT\r\n")
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
          "If-Modified-Since future date returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
