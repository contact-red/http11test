use "net"
use "../wire"
use "../runner"

actor HeadGetCtParity is WireCallback
  """
  RFC 9110 §9.3.2: content type

  Covers rfc9110-9.3.2-02 (SHOULD) on the Content-Type axis: HEAD must
  send the same Content-Type as the equivalent GET would. Cache layers
  (browsers, proxies, CDNs) inspect HEAD headers when validating cached
  representations — a mismatch silently corrupts the cache.

  PASS iff both responses have Content-Type and they're equal, OR both
  responses lack Content-Type (parity case; some libraries skip CT and
  leave it to the application).
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-9.3.2-02-content-type"

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

    // Sanity: response 2 should parse as HTTP/1.x.
    match ResponseParser.status_code(r2_bytes)
    | let _: U16 => None
    | let err: ParseError =>
      _reporter.fail(_test_id, "GET response: " + err.describe())
      return
    end

    let r1_ct = ResponseParser.find_header_value(r1_bytes, "content-type")
    let r2_ct = ResponseParser.find_header_value(r2_bytes, "content-type")

    match r1_ct
    | None =>
      match r2_ct
      | None => _reporter.pass(_test_id)
      | let v: String =>
        _reporter.fail(_test_id,
          "HEAD has no Content-Type but GET has \"" + v + "\"")
      end
    | let ct1: String =>
      match r2_ct
      | None =>
        _reporter.fail(_test_id,
          "HEAD has Content-Type \"" + ct1 + "\" but GET has none")
      | let ct2: String =>
        if ct1 == ct2 then
          _reporter.pass(_test_id)
        else
          _reporter.fail(_test_id,
            "HEAD CT \"" + ct1 + "\" != GET CT \"" + ct2 + "\"")
        end
      end
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
