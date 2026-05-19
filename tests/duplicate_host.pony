use "../runner"

primitive DuplicateHost
  """
  Covers rfc9112-3.2-06 (duplicate Host variant): a server MUST respond with
  400 (Bad Request) when more than one Host header field line is present.
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end
    RejectSpec.one_code("rfc9112-3.2-06-duplicate", 400, request)
