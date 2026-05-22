use "net"
use "../wire"
use "../runner"

actor PathDoubleEncodedTraversal is WireCallback
  """
  `%252E` is `%2E` percent-encoded — a double-encoding of `.`. A
  naive decoder that decodes once gets `%2E` → `.`, and again gets
  `.`, exposing path traversal. Servers should decode exactly once
  per RFC 3986. We accept any non-5xx — what we don't want is a
  server that reaches outside the document root.
  """
  let _reporter: Reporter
  let _test_id: String = "interop-double-encoded-traversal"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET /%252E%252E/secret HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 600) and (code != 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "double-encoded traversal returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
