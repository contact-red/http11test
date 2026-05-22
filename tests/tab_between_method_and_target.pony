use "../runner"

primitive TabBetweenMethodAndTarget
  """
  RFC 9112 §3: request-line elements are separated by single SP
  (0x20). Tab is not allowed as a separator. Server must respond
  400.
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      "GET\t/ HTTP/1.1\r\nHost: " + host + "\r\nConnection: close\r\n\r\n"
    end
    RejectSpec.one_code("rfc9112-3-05-tab-method-target", 400, request)
