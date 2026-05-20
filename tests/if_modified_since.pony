use "net"
use "../wire"
use "../runner"

actor IfModifiedSinceOld is WireCallback
  """
  Browsers send `If-Modified-Since` on every cached resource. The
  server must accept and process the header — for resources without
  validators (our default endpoints) returning 200 is correct. For
  resources with mtime later than the IMS date, also 200. We pick an
  intentionally ancient date so the resource is always considered
  modified.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-if-modified-since"

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
      s.append("\r\nIf-Modified-Since: Sun, 06 Nov 1994 08:49:37 GMT\r\n")
      s.append("Connection: close\r\n\r\n")
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
          "GET with If-Modified-Since returned " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
