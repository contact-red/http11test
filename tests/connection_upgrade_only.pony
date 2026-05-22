use "net"
use "../wire"
use "../runner"

actor ConnectionUpgradeOnly is WireCallback
  """
  `Connection: Upgrade` (without an actual Upgrade header) is malformed
  per RFC 9110 §7.6.1 — Upgrade-token in Connection must be paired
  with an Upgrade header — but a server shouldn't crash. We accept any
  HTTP response. Stallion's lookup that does not find `close` or
  `keep-alive` should fall through to the HTTP/1.1 default (keep-alive)
  and respond normally.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-7.6.1-06-upgrade-token"

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
      s.append("\r\nConnection: Upgrade\r\nConnection: close\r\n\r\n")
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
          "Connection: Upgrade returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
