use "net"
use "../wire"
use "../runner"

actor NoDuplicateContentLength is WireCallback
  """
  RFC 9112 §6.1: a response with multiple Content-Length values (or
  multiple distinct CL headers) is malformed. Per RFC 9110 §8.6, a server
  MUST NOT send Content-Length more than once. We expect exactly one CL
  header on a 200 GET / response.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-8.6-13-no-duplicate-cl-resp"

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
    | let code: U16 if (code >= 200) and (code < 300) =>
      let n = ResponseParser.count_header(bytes, "content-length")
      // n=0 is acceptable when framing is via Transfer-Encoding or close;
      // n>1 is the violation we're hunting.
      if n <= 1 then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "response contained " + n.string() + " Content-Length headers")
      end
    | let code: U16 =>
      _reporter.fail(_test_id, "non-2xx status " + code.string())
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
