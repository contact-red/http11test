use "../runner"

primitive MissingHost
  """
  RFC 9112 §3.2: missing

  Covers rfc9112-3.2-06 (missing Host variant): a server MUST respond with
  400 (Bad Request) to any HTTP/1.1 request message that lacks a Host
  header field. We send a syntactically valid request without any Host.
  """
  fun apply(host: String): RejectSpec =>
    let request: String val = "GET / HTTP/1.1\r\nConnection: close\r\n\r\n"
    RejectSpec.one_code("rfc9112-3.2-06-missing", 400, request)
