use "../runner"

primitive UriTooLong
  """
  Covers rfc9112-3-03: a server MUST respond with 414 (URI Too Long) when
  the request-target is longer than any URI it wishes to parse. We send a
  request-target of 64 KiB of 'A' characters, comfortably above the RFC's
  recommended 8000-octet minimum support.
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      let s = String(70_000)
      s.append("GET /")
      var i: USize = 0
      while i < 65_536 do
        s.push('A')
        i = i + 1
      end
      s.append(" HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end
    RejectSpec.one_code("rfc9112-3-03", 414, request)
