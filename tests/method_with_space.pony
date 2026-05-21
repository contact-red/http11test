use "../runner"

primitive MethodWithSpace
  """
  `GE T / HTTP/1.1` — a space inside the method splits the request-
  line into 4 components instead of 3. Server should reject 400.
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      "GE T / HTTP/1.1\r\nHost: " + host + "\r\nConnection: close\r\n\r\n"
    end
    RejectSpec.one_code("rfc9112-3-04-method-with-space", 400, request)
