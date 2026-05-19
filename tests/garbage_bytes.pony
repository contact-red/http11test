use "../runner"

primitive GarbageBytes
  """
  Covers rfc9112-2.2-10: when a server receives octets that don't match the
  HTTP-message grammar (aside from the leading-CRLF robustness exception),
  it SHOULD respond with 400 (Bad Request). We send a request-line missing
  its HTTP-version component.
  """
  fun apply(host: String): RejectSpec =>
    let request: String val = "GET /\r\nHost: " + host + "\r\nConnection: close\r\n\r\n"
    RejectSpec.one_code("rfc9112-2.2-10", 400, request)
