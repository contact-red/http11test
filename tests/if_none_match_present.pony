use "net"
use "../wire"
use "../runner"

actor IfNoneMatchPresent is WireCallback
  """
  Browsers send `If-None-Match` on cached resources. The server may
  return 304 if the etag matches, 200 otherwise. For resources without
  validators (most of our default endpoints), 200 is expected.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-13.1.2-01-if-none-match"

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
      s.append("\r\nIf-None-Match: \"some-etag-value\"\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // 200 if no validator match; 304 if (somehow) it matches. Both OK.
      if (code == 200) or (code == 304) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "GET with If-None-Match returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
