use "../runner"

primitive EmptyMethodLeadingSpace
  """
  RFC 9112 §3: request-line starts with method. A leading space
  before any method bytes is malformed. Server should respond 400.
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      " / HTTP/1.1\r\nHost: " + host + "\r\nConnection: close\r\n\r\n"
    end
    RejectSpec.one_code("rfc9112-3-07-empty-method", 400, request)
