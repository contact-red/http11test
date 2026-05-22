use "net"
use "../wire"
use "../runner"

actor HeadGetServerParity is WireCallback
  """
  RFC 9110 §9.3.2: server

  Covers rfc9110-9.3.2-02 (SHOULD) on the Server-header axis: HEAD
  must mirror GET on Server identification. Mismatches in Server
  between HEAD and GET trip identification logic in middleboxes and
  monitoring tools that classify origins by Server fingerprint.

  PASS iff both responses have Server and they're equal, OR both lack
  Server (parity case; bandit, hyper, stallion all omit Server by
  default).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.3.2-02-server"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let requests = recover val
      let s = String
      s.append("HEAD / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\n\r\n")
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, requests, this)

  be on_response(bytes: Array[U8] val) =>
    let r1_end = match ResponseParser.body_offset(bytes)
    | let n: USize => n
    | let err: ParseError =>
      _reporter.fail(_test_id, "HEAD response: " + err.describe())
      return
    end

    let r1_bytes = bytes.trim(0, r1_end)
    let r2_bytes = bytes.trim(r1_end)

    match ResponseParser.status_code(r2_bytes)
    | let _: U16 => None
    | let err: ParseError =>
      _reporter.fail(_test_id, "GET response: " + err.describe())
      return
    end

    let r1_srv = ResponseParser.find_header_value(r1_bytes, "server")
    let r2_srv = ResponseParser.find_header_value(r2_bytes, "server")

    match r1_srv
    | None =>
      match r2_srv
      | None => _reporter.pass(_test_id)
      | let v: String =>
        _reporter.fail(_test_id,
          "HEAD has no Server but GET has \"" + v + "\"")
      end
    | let s1: String =>
      match r2_srv
      | None =>
        _reporter.fail(_test_id,
          "HEAD has Server \"" + s1 + "\" but GET has none")
      | let s2: String =>
        if s1 == s2 then
          _reporter.pass(_test_id)
        else
          _reporter.fail(_test_id,
            "HEAD Server \"" + s1 + "\" != GET Server \"" + s2 + "\"")
        end
      end
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
