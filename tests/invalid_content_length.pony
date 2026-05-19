use "../runner"

primitive InvalidContentLength
  """
  Covers rfc9112-6.3-04 / rfc9112-6.3-05: a recipient of an invalid
  Content-Length MUST treat it as unrecoverable; a server with this error
  in a request MUST respond with 400 (Bad Request) and close. We send
  `Content-Length: abc`, which is plainly not a decimal numeral.
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      let s = String
      s.append("POST / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nContent-Length: abc\r\nConnection: close\r\n\r\n")
      s
    end
    RejectSpec.one_code("rfc9112-6.3-04", 400, request)
