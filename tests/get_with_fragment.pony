use "net"
use "../wire"
use "../runner"

actor GetWithFragment is WireCallback
  """
  RFC 9110 §7.1: "Fragment identifiers are not allowed in HTTP request
  messages." Real clients strip them client-side, but a server that
  receives one (perhaps from a buggy client or a hostile peer) should
  respond — typically by ignoring the fragment portion. We accept any
  non-5xx so this works against both lenient and strict servers.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-7.1-01-fragment-in-target"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /page#section HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "GET with fragment returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
