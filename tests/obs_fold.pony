use "../runner"

primitive ObsFold
  """
  Covers rfc9112-5.2-02: a server that receives an obs-fold (a header line
  continued onto the next line via SP/HTAB at the start) MUST either reject
  with 400 or replace the obs-fold with one or more SP octets. We assert
  400. Servers that normalize will FAIL — informative either way.
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nX-Folded: line-one\r\n line-two\r\nConnection: close\r\n\r\n")
      s
    end
    RejectSpec.one_code("rfc9112-5.2-02", 400, request)
