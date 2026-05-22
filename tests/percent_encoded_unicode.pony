use "net"
use "../wire"
use "../runner"

actor PercentEncodedUnicode is WireCallback
  """
  UTF-8 multi-byte characters in URLs arrive percent-encoded (RFC 3986
  §2.5). `%C3%A9` is `é` in UTF-8. Server must accept and treat as
  opaque path bytes.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-2.1-04-encoded-unicode"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /caf%C3%A9 HTTP/1.1\r\nHost: ")
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
          "percent-encoded unicode returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
