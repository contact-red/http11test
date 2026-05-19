use "../runner"

primitive OversizeHeader
  """
  Covers rfc9110-5.4-01: a server that receives a header field line, value,
  or set of fields larger than it wishes to process MUST respond with an
  appropriate 4xx. Common codes are 400 (Bad Request) and 431 (Request
  Header Fields Too Large); we accept either.
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      let s = String(110_000)
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nX-Big: ")
      var i: USize = 0
      while i < 100_000 do
        s.push('A')
        i = i + 1
      end
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end
    let expected = recover val [as U16: 400; 431] end
    RejectSpec("rfc9110-5.4-01", expected, request)
