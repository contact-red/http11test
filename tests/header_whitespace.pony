use "../runner"

primitive HeaderWhitespace
  """
  Covers rfc9112-5.1-01: a server MUST reject, with 400 (Bad Request), any
  request that contains whitespace between a header field name and its
  colon. We send `Host : host` (note the SP before the colon).
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost : ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end
    RejectSpec.one_code("rfc9112-5.1-01", 400, request)
