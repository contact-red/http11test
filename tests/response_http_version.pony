use "net"
use "../wire"
use "../runner"

actor ResponseHttpVersion is WireCallback
  """
  Covers rfc9110-6.2-04 (SHOULD): a server SHOULD send a response version
  equal to the highest version to which the server is conformant that
  has a major version less than or equal to the one received in the
  request. We send HTTP/1.1 and expect the response start-line to begin
  with "HTTP/1.1 " exactly.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9110-6.2-04"

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
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    if bytes.size() < 9 then
      _reporter.fail(_test_id, "response too short")
      return
    end

    try
      let prefix_ok =
        (bytes(0)? == 'H')
          and (bytes(1)? == 'T')
          and (bytes(2)? == 'T')
          and (bytes(3)? == 'P')
          and (bytes(4)? == '/')
          and (bytes(5)? == '1')
          and (bytes(6)? == '.')
          and (bytes(7)? == '1')
          and (bytes(8)? == ' ')
      if prefix_ok then
        _reporter.pass(_test_id)
      else
        // Report what we got — first 8 chars of the start-line.
        let actual = recover val
          let s = String
          var i: USize = 0
          while (i < 8) and (i < bytes.size()) do
            s.push(bytes(i)?)
            i = i + 1
          end
          s
        end
        _reporter.fail(_test_id,
          "expected response to start with \"HTTP/1.1 \", got \"" + actual + "\"")
      end
    else
      _reporter.fail(_test_id, "bounds error reading start-line")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
