use "net"
use "../wire"
use "../runner"

actor TeChunkedNotLast is WireCallback
  """
  RFC 9112 §6.1: "If any transfer coding other than chunked is applied
  to a request's content, the sender MUST apply chunked as the final
  transfer coding to ensure that the message is properly framed."

  We send `Transfer-Encoding: chunked, gzip` — chunked is not last,
  so the request is malformed. Server MUST reject. Per §6.3, the
  recommended status is 400 or 501.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-6.1-01-chunked-not-last"

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
      s.append("\r\nTransfer-Encoding: chunked, gzip\r\n")
      s.append("Connection: close\r\n\r\n0\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 400) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "chunked-not-last returned " + code.string() + " (expected 4xx/501)")
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
