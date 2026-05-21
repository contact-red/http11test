use "net"
use "../wire"
use "../runner"

actor ResponseReasonPhraseAscii is WireCallback
  """
  RFC 9112 §4: the reason-phrase in a status-line is composed of
  HTAB / SP / VCHAR / obs-text — i.e., printable ASCII plus tab.
  Anything else (bare CR, LF inside the reason, control chars) would
  break clients and intermediaries. This check ensures the reason
  phrase between the third space and the terminating CRLF contains
  only legal bytes.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-4-04-reason-phrase-ascii"

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
    // Validate that the bytes between the 3rd space and the first CRLF
    // are all HTAB, SP, or VCHAR (0x21..0x7E).
    try
      var spaces_seen: USize = 0
      var reason_start: USize = 0
      var i: USize = 0
      while (i < bytes.size()) and (spaces_seen < 2) do
        if bytes(i)? == ' ' then spaces_seen = spaces_seen + 1 end
        i = i + 1
      end
      reason_start = i  // first byte after "HTTP/1.x NNN "

      var j: USize = reason_start
      while (j + 1) < bytes.size() do
        if (bytes(j)? == '\r') and (bytes(j + 1)? == '\n') then
          break
        end
        let b = bytes(j)?
        // Allowed: HTAB (0x09), SP (0x20), VCHAR (0x21..0x7E).
        let ok = (b == 0x09) or (b == 0x20)
          or ((b >= 0x21) and (b <= 0x7E))
        if not ok then
          _reporter.fail(_test_id,
            "reason-phrase contains byte 0x" + b.string()
              + " at offset " + j.string())
          return
        end
        j = j + 1
      end
      _reporter.pass(_test_id)
    else
      _reporter.fail(_test_id, "response too short to validate reason-phrase")
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
