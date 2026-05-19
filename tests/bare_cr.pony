use "../runner"

primitive BareCr
  """
  Covers rfc9112-2.2-04 and rfc9110-5.5-04: a recipient of a bare CR (a CR
  not immediately followed by LF) within a protocol element MUST consider
  the element invalid (or replace each bare CR with SP). We send a bare CR
  inside the Host field value. We assert 400 here — servers that normalize
  CR -> SP instead will FAIL this test, which is itself useful information.
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.push('\r')
      s.append("X-After-Bad: x\r\nConnection: close\r\n\r\n")
      s
    end
    RejectSpec.one_code("rfc9112-2.2-04", 400, request)
