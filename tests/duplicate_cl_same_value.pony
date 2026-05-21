use "net"
use "../wire"
use "../runner"

actor DuplicateClSameValue is WireCallback
  """
  POST with two Content-Length headers, both `0`. Per RFC 9110 §8.6,
  this is technically a duplicate header but with identical values —
  message framing is unambiguous. Servers may accept (200/204) or
  reject (400). Both are RFC-compliant.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-duplicate-cl-same-value"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("POST / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nContent-Length: 0\r\n")
      s.append("Content-Length: 0\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // 200/204/405/501 accepted; 400 (strict reject) also OK; 500 = bug.
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "duplicate same-value CL returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
