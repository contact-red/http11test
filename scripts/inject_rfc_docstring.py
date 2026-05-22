#!/usr/bin/env python3
"""
For each test file whose docstring lacks any "RFC" mention, prepend a
one-line RFC reference derived from the test ID. The test IDs already
encode the RFC + section, so we just reformat the ID's prefix back
into prose.

Example transformation:

  Before:
    actor Foo is WireCallback
      \"\"\"
      Description.
      \"\"\"
      ...
      let _test_id: String = "rfc9110-5.5-07-value-with-braces"

  After:
    actor Foo is WireCallback
      \"\"\"
      RFC 9110 §5.5: value-with-braces

      Description.
      \"\"\"
      ...
      let _test_id: String = "rfc9110-5.5-07-value-with-braces"
"""

import re
from pathlib import Path

# Map ID prefix → RFC + how to format the section number
def parse_id(test_id: str) -> tuple[str, str, str] | None:
    """
    Returns (rfc_label, section, slug) or None.

    test_id like "rfc9110-5.6.2-03-1-char-special-tchar" parses as:
      rfc_label = "RFC 9110"
      section = "5.6.2"
      slug = "1-char-special-tchar"
    """
    m = re.match(r'(rfc\d+|fetch|upgrade-insecure-requests)-([\d.]+)-(\d+)-(.+)', test_id)
    if not m:
        return None
    prefix, section, _seq, slug = m.groups()

    rfc_label_map = {
        "rfc3986": "RFC 3986",
        "rfc4918": "RFC 4918",
        "rfc5789": "RFC 5789",
        "rfc5891": "RFC 5891",
        "rfc6265": "RFC 6265",
        "rfc6454": "RFC 6454",
        "rfc6455": "RFC 6455",
        "rfc6750": "RFC 6750",
        "rfc7239": "RFC 7239",
        "rfc7616": "RFC 7616",
        "rfc9110": "RFC 9110",
        "rfc9111": "RFC 9111",
        "rfc9112": "RFC 9112",
        "fetch": "Fetch",
        "upgrade-insecure-requests": "W3C Upgrade-Insecure-Requests",
    }
    rfc_label = rfc_label_map.get(prefix, prefix.upper())
    return rfc_label, section, slug

def file_has_rfc_mention(text: str) -> bool:
    # Look for "RFC" anywhere in the docstring portion (between """ ... """).
    # First docstring is what we care about.
    m = re.search(r'"""(.*?)"""', text, re.DOTALL)
    if not m:
        return False
    return "RFC" in m.group(1) or "Fetch" in m.group(1)

def inject_ref(text: str, test_id: str) -> str | None:
    parsed = parse_id(test_id)
    if not parsed:
        return None
    rfc_label, section, slug = parsed
    section_part = f"§{section}" if section else ""
    ref_line = f"  {rfc_label} {section_part}: {slug.replace('-', ' ')}".rstrip()

    # Find the first docstring opening (after actor/class/primitive line).
    m = re.search(r'("""\n)', text)
    if not m:
        return None
    insert_at = m.end()
    return text[:insert_at] + ref_line + "\n\n" + text[insert_at:]

def main():
    tests = Path("tests")
    updated = 0
    skipped = 0
    for f in sorted(tests.glob("*.pony")):
        text = f.read_text()
        if file_has_rfc_mention(text):
            skipped += 1
            continue
        m = re.search(r'_test_id: String = "([^"]+)"', text)
        if not m:
            m = re.search(r'one_code\("([^"]+)"', text)
        if not m:
            continue
        test_id = m.group(1)
        new_text = inject_ref(text, test_id)
        if new_text is None:
            print(f"  could not parse: {f.name} ({test_id})")
            continue
        f.write_text(new_text)
        updated += 1
        print(f"  + {f.name}: {test_id}")
    print(f"---\n{updated} docstrings updated, {skipped} already had RFC mention.")

if __name__ == "__main__":
    main()
