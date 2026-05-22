use "net"
use "../wire"
use "../runner"

actor RepeatedQueryKey is WireCallback
  """
  GET /?tag=red&tag=green&tag=blue — repeated query keys are common
  (multi-select forms, array params). Server must accept; parsing is
  the application's concern.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.4-06-repeated-key"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /?tag=red&tag=green&tag=blue HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
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
          "repeated query key returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
