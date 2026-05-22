use "net"
use "../wire"
use "../runner"

actor SecChUaHeaders is WireCallback
  """
  Sec-CH-UA-* client hints (W3C Client Hints draft) — sent by modern
  Chromium browsers in lieu of (or alongside) the User-Agent string.
  Server must accept the quoted-string syntax.
  """
  let _reporter: Reporter
  let _test_id: String = "client-hints-3-01-sec-ch-ua"

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
      s.append("\r\nSec-CH-UA: \"Chromium\";v=\"119\", \"Not?A_Brand\";v=\"24\"\r\n")
      s.append("Sec-CH-UA-Mobile: ?0\r\n")
      s.append("Sec-CH-UA-Platform: \"Linux\"\r\n")
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
          "Sec-CH-UA headers returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
