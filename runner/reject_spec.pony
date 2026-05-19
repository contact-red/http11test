class val RejectSpec
  """
  Specification for a "send these bytes, expect a status code in this set"
  test. Used for both reject tests (expecting 4xx/5xx) and simple accept tests
  (expecting 2xx). Multiple expected codes accommodate requirements where the
  RFC permits more than one compliant outcome.
  """
  let id: String
  let expected_codes: Array[U16] val
  let request: ByteSeq

  new val create(
    id': String,
    expected_codes': Array[U16] val,
    request': ByteSeq)
  =>
    id = id'
    expected_codes = expected_codes'
    request = request'

  new val one_code(id': String, code: U16, request': ByteSeq) =>
    id = id'
    expected_codes = recover val [as U16: code] end
    request = request'

  fun accepts(code: U16): Bool =>
    for c in expected_codes.values() do
      if c == code then return true end
    end
    false

  fun expected_summary(): String =>
    """
    Human-readable description of the accepted code set, for error messages.
    Single code -> "414"; multiple -> "one of [400, 431]".
    """
    recover val
      let s = String
      let n = expected_codes.size()
      if n > 1 then s.append("one of [") end
      var first = true
      for c in expected_codes.values() do
        if not first then s.append(", ") end
        s.append(c.string())
        first = false
      end
      if n > 1 then s.append("]") end
      s
    end
