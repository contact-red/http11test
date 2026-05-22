use "net"
use "../wire"
use "../runner"

actor BareLfRequest is WireCallback
  """
  RFC 9112 §2.2: HTTP message line terminator is CRLF. A request that
  uses bare LF (no CR) is malformed. Strict servers reject 400;
  lenient servers (including nginx, caddy) treat bare LF as if it
  were CRLF. Either is acceptable here — what we're guarding against
  is a server hanging on the request, which would suggest the parser
  is in an unrecoverable state waiting for an `\\r` byte.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-bare-lf-request"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\nHost: ")
      s.append(host)
      s.append("\nConnection: close\n\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      // Any HTTP response is acceptable; the failure mode is timeout.
      if (code >= 200) and (code < 600) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "bare-LF request returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
