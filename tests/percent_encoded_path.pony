use "net"
use "../wire"
use "../runner"

actor PercentEncodedPath is WireCallback
  """
  Browsers percent-encode anything in the URL outside the unreserved
  set. Server must accept `%XX` sequences in the path component. We
  send `/foo%20bar` (space encoded) and expect a sane response (any
  2xx-4xx is OK; some servers will treat the path as not-mapped and
  return 200 if they have a catch-all, or 404 if they don't).
  """
  let _reporter: Reporter
  let _test_id: String = "interop-percent-encoded-path"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /foo%20bar HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // Accept any sane status — 200 catch-all, 404 not-found,
      // or 405 method-not-allowed. We're testing parser tolerance,
      // not routing semantics.
      if (code >= 200) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "GET /foo%20bar returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
