use "net"
use "../wire"
use "../runner"

actor ConnectionWithOws is WireCallback
  """
  RFC 9110 §5.6.1: comma-separated lists allow OWS around commas:
  `1#element = element *( OWS "," OWS element )`. Sending
  `Connection: keep-alive , close` (with surrounding OWS) is well-
  formed and the server must still see `close` and close the
  connection.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.6.1-01-comma-ows"

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
      s.append("\r\nConnection: keep-alive , close\r\n\r\n")
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
          "Connection with OWS around comma returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
