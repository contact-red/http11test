use "../runner"

primitive LeadingCrlf
  """
  Covers rfc9112-2.2-07 (accept variant): a server that is expecting to
  parse a request-line SHOULD ignore at least one empty line (CRLF)
  received prior to the request-line. We send `\\r\\n` followed by an
  otherwise valid GET / and accept 200 (or any 2xx the server returns
  for the root path).
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      let s = String
      s.append("\r\nGET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nConnection: close\r\n\r\n")
      s
    end
    let expected = recover val [as U16: 200; 204] end
    RejectSpec("rfc9112-2.2-07", expected, request)
