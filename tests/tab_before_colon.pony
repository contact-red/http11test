use "../runner"

primitive TabBeforeColon
  """
  RFC 9112 §5.1: "No whitespace is allowed between the header
  field-name and colon." We test SP before colon in
  `header_whitespace.pony`; this one tests HTAB. Server must reject 400.
  """
  fun apply(host: String): RejectSpec =>
    let request = recover val
      "GET / HTTP/1.1\r\nHost\t: " + host + "\r\nConnection: close\r\n\r\n"
    end
    RejectSpec.one_code("rfc9112-5.1-02-tab-before-colon", 400, request)
