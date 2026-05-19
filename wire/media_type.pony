primitive MediaType
  """
  Naive validator for Content-Type / Accept media-type values per RFC
  9110 §8.3. Checks structural form `type/subtype[; params]` — there's
  a non-empty type, a slash, a non-empty subtype, and the character
  after the subtype (if any) is `;` or whitespace.

  This is deliberately loose; full media-type / parameter parsing is
  more than the test needs.
  """
  fun is_valid(value: String): Bool =>
    if value.size() < 3 then return false end
    try
      var slash: USize = 0
      var found_slash = false
      var i: USize = 0
      while i < value.size() do
        let c = value(i)?
        if c == '/' then
          if found_slash then return false end
          slash = i
          found_slash = true
        elseif c == ';' then
          break
        end
        i = i + 1
      end
      if not found_slash then return false end
      if slash == 0 then return false end          // no type
      if (slash + 1) >= value.size() then return false end  // no subtype
      let after = value(slash + 1)?
      // First subtype char must be a token char (loosely: not space, /, ;).
      if (after == ' ') or (after == ';') or (after == '/') then return false end
      true
    else
      false
    end
