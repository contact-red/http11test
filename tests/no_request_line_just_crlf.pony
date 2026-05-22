use "../runner"

primitive NoRequestLineJustCrlf
  """
  RFC 9112 §2.2: double empty crlf

  A connection that sends only `\\r\\n\\r\\n` (no request-line at all)
  is malformed. Server should respond 400 — not loop forever or
  process as a malformed request. Sending one `\\r\\n` is the empty-
  line tolerance case from §2.2; two CRLFs is unambiguous malformed.
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      "\r\n\r\nGET garbage HTTP/1.1\r\nHost: " + host + "\r\nConnection: close\r\n\r\n"
    end
    RejectSpec.one_code("rfc9112-2.2-09-double-empty-crlf", 400, request)
