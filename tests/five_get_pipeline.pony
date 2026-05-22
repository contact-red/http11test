use "net"
use "../wire"
use "../runner"

actor FiveGetPipeline is WireCallback
  """
  Pipelined 5 identical GETs in one write. All 5 responses must come
  back in order. Stresses the parser's ability to re-enter
  _ExpectRequestLine cleanly after each request.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-9.3-02-five-get-pipeline"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let requests = recover val
      let s = String
      var i: USize = 0
      while i < 4 do
        s.append("GET / HTTP/1.1\r\nHost: ")
        s.append(host)
        s.append("\r\n\r\n")
        i = i + 1
      end
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, requests, this)

  be on_response(bytes: Array[U8] val) =>
    var pos: USize = 0
    var count: USize = 0
    while pos < bytes.size() do
      let slice = recover val bytes.trim(pos) end
      match ResponseParser.status_code(slice)
      | let code: U16 if (code < 200) or (code >= 300) =>
        _reporter.fail(_test_id,
          "response " + count.string() + " was " + code.string())
        return
      | let _: U16 => count = count + 1
      | let err: ParseError =>
        _reporter.fail(_test_id,
          "response " + count.string() + ": " + err.describe())
        return
      end

      let header_end = match ResponseParser.body_offset(slice)
      | let n: USize => n
      | let err: ParseError =>
        _reporter.fail(_test_id, err.describe())
        return
      end

      let body_len = match ResponseParser.content_length(slice)
      | let n: USize => n
      | let _: ParseError => 0
      end

      pos = pos + header_end + body_len
    end

    if count >= 5 then
      _reporter.pass(_test_id)
    else
      _reporter.fail(_test_id,
        "got " + count.string() + " responses; expected 5")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
