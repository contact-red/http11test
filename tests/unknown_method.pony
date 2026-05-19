use "../runner"

primitive UnknownMethod
  """
  Covers rfc9112-3-02: a server SHOULD respond 501 (Not Implemented) when
  it receives a method longer than any it implements. "WHATEVERMETHOD"
  (14 octets) is longer than any standard HTTP method.
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      let s = String
      s.append("WHATEVERMETHOD / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end
    RejectSpec.one_code("rfc9112-3-02", 501, request)
