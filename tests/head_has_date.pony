use "net"
use "../wire"
use "../runner"

actor HeadHasDate is WireCallback
  """
  Covers rfc9110-6.6.1-02 (MUST) on the HEAD side: an origin server with
  a clock generates a Date header field in all 2xx/3xx/4xx responses.
  Companion to DateHeaderFormat (which covers GET); browsers cache HEAD
  responses too, so HEAD Date is just as load-bearing as GET Date.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-6.6.1-02-head"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("HEAD / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code < 200) or (code >= 500) then
        _reporter.fail(_test_id,
          "HEAD / returned " + code.string())
        return
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
      return
    end

    match ResponseParser.find_header_value(bytes, "date")
    | let _: String => _reporter.pass(_test_id)
    | None => _reporter.fail(_test_id, "HEAD response has no Date header")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
