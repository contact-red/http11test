use "net"
use "../wire"
use "../runner"

actor InvalidHeaderNameChar is WireCallback
  """
  RFC 9110 §5.6.2: field-name is a `token`, which uses only tchars.
  `@`, `(`, `)`, `<`, `>`, `,`, `;`, `:` are NOT tchars. A header line
  with `@` in the field name (e.g. `Bad@Header: yes`) is malformed and
  the server MUST respond with 400.

  Stallion's parser extracts everything before the colon as the
  field-name without validating tchars, so it silently accepts.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-5.6.2-01-tchar-field-name"

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
      s.append("\r\nBad@Header: yes\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 400) and (code < 500) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "invalid tchar in field-name returned " + code.string()
            + " (expected 4xx)")
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
