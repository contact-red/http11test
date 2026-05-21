primitive ParseEmptyResponse
  fun describe(): String => "server sent no data"

primitive ParseNotHttp1x
  fun describe(): String => "response did not begin with \"HTTP/1.\""

primitive ParseInvalidStatusCode
  fun describe(): String => "could not parse 3-digit status code"

primitive ParseUnterminatedHeaders
  fun describe(): String => "response headers not terminated with CRLF CRLF"

primitive ParseNoContentLength
  fun describe(): String => "response has no Content-Length header"

primitive ParseInvalidContentLength
  fun describe(): String => "Content-Length value could not be parsed"

type ParseError is
  ( ParseEmptyResponse
  | ParseNotHttp1x
  | ParseInvalidStatusCode
  | ParseUnterminatedHeaders
  | ParseNoContentLength
  | ParseInvalidContentLength )

primitive ResponseParser
  """
  Tolerant response parsing used only for assertions in tests.

  Tests construct exact request bytes themselves; the parser's job is to
  extract just enough information for an assertion (status code, header
  presence, etc.) without re-implementing a full HTTP parser. When the
  response can't be understood, we return a ParseError so the runner can
  produce a meaningful failure message.
  """
  fun status_code(bytes: Array[U8] val): (U16 | ParseError) =>
    """
    Extract the 3-digit status code from the response start-line, or
    describe why the response can't be interpreted as HTTP/1.x.
    """
    if bytes.size() == 0 then return ParseEmptyResponse end
    // Minimum legal status-line: "HTTP/1.x NNN\r\n" = 14 bytes; require
    // enough to host "HTTP/1." + at least " NNN".
    if bytes.size() < 12 then return ParseNotHttp1x end

    try
      // Require literal "HTTP/1." prefix; anything else (HTTP/0.9 body,
      // junk, etc.) is reported as not HTTP/1.x.
      if (bytes(0)? != 'H')
        or (bytes(1)? != 'T')
        or (bytes(2)? != 'T')
        or (bytes(3)? != 'P')
        or (bytes(4)? != '/')
        or (bytes(5)? != '1')
        or (bytes(6)? != '.')
      then
        return ParseNotHttp1x
      end

      // Skip the minor-version digit(s) up to the SP that separates the
      // HTTP-version from the status-code.
      var sp1: USize = 7
      while sp1 < bytes.size() do
        if bytes(sp1)? == ' ' then break end
        sp1 = sp1 + 1
      end
      if sp1 >= bytes.size() then return ParseInvalidStatusCode end

      let code_start = sp1 + 1
      let code_end = code_start + 3
      if code_end > bytes.size() then return ParseInvalidStatusCode end

      var code: U16 = 0
      var i: USize = code_start
      while i < code_end do
        let b = bytes(i)?
        if (b < '0') or (b > '9') then return ParseInvalidStatusCode end
        code = (code * 10) + (b - '0').u16()
        i = i + 1
      end
      code
    else
      // Bounds error despite size checks. Shouldn't happen; if it does,
      // surface as "couldn't parse" rather than crash.
      ParseInvalidStatusCode
    end

  fun body_offset(bytes: Array[U8] val): (USize | ParseError) =>
    """
    Returns the byte offset of the start of the message body — the first
    byte after the CRLF CRLF that terminates the header section. If no
    such terminator is found, returns ParseUnterminatedHeaders.
    """
    if bytes.size() < 4 then return ParseEmptyResponse end
    try
      var i: USize = 0
      while (i + 3) < bytes.size() do
        if (bytes(i)? == '\r')
          and (bytes(i + 1)? == '\n')
          and (bytes(i + 2)? == '\r')
          and (bytes(i + 3)? == '\n')
        then
          return i + 4
        end
        i = i + 1
      end
      ParseUnterminatedHeaders
    else
      ParseUnterminatedHeaders
    end

  fun content_length(bytes: Array[U8] val): (USize | ParseError) =>
    """
    Find a Content-Length header in the response and return its value.
    Case-insensitive on the field name. Skips OWS after the colon.
    """
    let body_start = match body_offset(bytes)
    | let n: USize => n
    | let err: ParseError => return err
    end
    // Search within the header section only (everything before body_start - 4).
    let header_end = body_start - 4
    let needle = "content-length"
    try
      var i: USize = 0
      while (i + needle.size()) <= header_end do
        // The header line must start either at offset 0 (immediately
        // after the status-line is impossible since the first line is the
        // status-line, but be defensive) or after a CRLF.
        let at_line_start =
          (i == 0)
            or ((i >= 2)
                  and (bytes(i - 2)? == '\r')
                  and (bytes(i - 1)? == '\n'))
        if at_line_start and _match_ci(bytes, i, needle)? then
          var j: USize = i + needle.size()
          if (j >= bytes.size()) or (bytes(j)? != ':') then
            i = i + 1
            continue
          end
          j = j + 1
          // Skip OWS.
          while (j < bytes.size())
            and ((bytes(j)? == ' ') or (bytes(j)? == '\t'))
          do
            j = j + 1
          end
          // Parse digits.
          var value: USize = 0
          var saw_digit = false
          while (j < bytes.size()) do
            let b = bytes(j)?
            if (b < '0') or (b > '9') then break end
            value = (value * 10) + (b - '0').usize()
            saw_digit = true
            j = j + 1
          end
          if not saw_digit then return ParseInvalidContentLength end
          return value
        end
        i = i + 1
      end
      ParseNoContentLength
    else
      ParseInvalidContentLength
    end

  fun count_header(bytes: Array[U8] val, name: String): USize =>
    """
    Count how many times `name` (expected lowercase) appears as a field-name
    in the response header section. Case-insensitive on the field name.
    Returns 0 if the response can't be parsed.
    """
    let body_start = match body_offset(bytes)
    | let n: USize => n
    | let _: ParseError => return 0
    end
    if body_start < 4 then return 0 end
    let header_end = body_start - 4
    var count: USize = 0
    try
      var i: USize = 0
      while (i + name.size()) <= header_end do
        let at_line_start =
          (i == 0)
            or ((i >= 2)
                  and (bytes(i - 2)? == '\r')
                  and (bytes(i - 1)? == '\n'))
        if at_line_start and _match_ci(bytes, i, name)? then
          let j: USize = i + name.size()
          if (j < bytes.size()) and (bytes(j)? == ':') then
            count = count + 1
          end
        end
        i = i + 1
      end
    end
    count

  fun _match_ci(bytes: Array[U8] val, offset: USize, needle: String): Bool ? =>
    """
    Case-insensitive match of `needle` (which must be lowercase) against
    `bytes` starting at `offset`. Errors if `offset + needle.size() >
    bytes.size()` (callers are expected to bounds-check first; this only
    errors on partial reads inside the loop).
    """
    var i: USize = 0
    while i < needle.size() do
      let b = bytes(offset + i)?
      let lower = if (b >= 'A') and (b <= 'Z') then b + 32 else b end
      if lower != needle(i)? then return false end
      i = i + 1
    end
    true

  fun find_header_value(
    bytes: Array[U8] val,
    name: String)
    : (String val | None)
  =>
    """
    Look up `name` (expected lowercase) in the response header section
    case-insensitively. Returns the trimmed field value as a String, or
    None if the header is absent (or the response can't be parsed).
    """
    let body_start = match body_offset(bytes)
    | let n: USize => n
    | let _: ParseError => return None
    end
    if body_start < 4 then return None end
    let header_end = body_start - 4
    try
      var i: USize = 0
      while (i + name.size()) <= header_end do
        let at_line_start =
          (i == 0)
            or ((i >= 2)
                  and (bytes(i - 2)? == '\r')
                  and (bytes(i - 1)? == '\n'))
        if at_line_start and _match_ci(bytes, i, name)? then
          var j: USize = i + name.size()
          if (j >= bytes.size()) or (bytes(j)? != ':') then
            i = i + 1
            continue
          end
          j = j + 1
          // Skip leading OWS.
          while (j < bytes.size())
            and ((bytes(j)? == ' ') or (bytes(j)? == '\t'))
          do
            j = j + 1
          end
          let value_start = j
          // Walk to CRLF (or end of header section).
          while (j + 1) < bytes.size() do
            if (bytes(j)? == '\r') and (bytes(j + 1)? == '\n') then
              break
            end
            j = j + 1
          end
          // Strip trailing OWS.
          var value_end = j
          while (value_end > value_start)
            and ((bytes(value_end - 1)? == ' ')
              or (bytes(value_end - 1)? == '\t'))
          do
            value_end = value_end - 1
          end
          return String.from_array(bytes.trim(value_start, value_end))
        end
        i = i + 1
      end
      None
    else
      None
    end
