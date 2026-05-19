use "net"
use "../wire"
use "../runner"

actor MultipleConnectionOptions is WireCallback
  """
  RFC 9112 §7.6.1 / 9.6: the Connection header is a comma-separated
  list. Real-world traffic from chained proxies often arrives with
  multiple options like `Connection: close, te` or `Connection: keep-
  alive, upgrade`. The server must parse the list and respect each
  option's semantics (here: close after responding).

  We send `Connection: close, x-fake-option` and expect the server to
  return a normal 2xx and close the connection (otherwise the wire
  harness would hang waiting for closed).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-9.6-03-list"

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
      s.append("\r\nConnection: close, x-fake-option\r\n\r\n")
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
          "multi-option Connection returned " + code.string())
      end
    | let err: ParseError =>
      _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
