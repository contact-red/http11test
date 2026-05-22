use "net"
use "../wire"
use "../runner"

actor GetWithBody is WireCallback
  """
  RFC 9110 §9.3.1: a GET payload has no defined semantics. Servers
  typically still consume the body and respond normally. We send GET
  with Content-Length: 5 and 5 bytes after the headers; accept 2xx
  (consumed and ignored) or 4xx (rejected). Hanging on the body read
  is the failure we're hunting.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.3.1-02-get-with-body"

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
      s.append("\r\nContent-Length: 5\r\n")
      s.append("Connection: close\r\n\r\nhello")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // 2xx (body consumed and ignored) or 4xx (rejected) both compliant.
      if ((code >= 200) and (code < 300)) or ((code >= 400) and (code < 500)) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "GET with body returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
