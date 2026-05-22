use "net"
use "../wire"
use "../runner"

actor UnknownExpectation is WireCallback
  """
  RFC 9110 §10.1.1: "A server that receives an Expect field value
  containing a member other than 100-continue MAY respond with a 417
  (Expectation Failed) status code to indicate that the unexpected
  expectation cannot be met."

  We send `Expect: foo-bar` and accept 417 (strict) or 2xx (ignored).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-10.1.1-02-unknown-expectation"

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
      s.append("\r\nExpect: foo-bar\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if ((code >= 200) and (code < 300)) or (code == 417) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "unknown Expect returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
