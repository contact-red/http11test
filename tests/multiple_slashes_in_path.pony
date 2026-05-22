use "net"
use "../wire"
use "../runner"

actor MultipleSlashesInPath is WireCallback
  """
  RFC 3986 §3.3: multiple slashes

  Real URLs sometimes contain `//` from naive concatenation
  (`https://host/` + `/path`) or proxy rewrites. Servers must accept
  multiple slashes in the path component without rejecting the
  request.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc3986-3.3-03-multiple-slashes"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET //a///b/c HTTP/1.1\r\nHost: ")
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
          "GET with multiple slashes in path returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
