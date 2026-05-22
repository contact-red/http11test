#!/usr/bin/env python3
"""
Rename `interop-*` test IDs to RFC-anchored IDs (`rfc<num>-<section>-<NN>-<slug>`),
and add an "RFC <X> §<Y>" reference line to docstrings that lack one.

The mapping below is hand-curated: each interop-* ID is assigned an
RFC + section that best matches what the test exercises.
"""

import re
from pathlib import Path

# interop-* → (new_id, "RFC <X> §<sec>: <one-line reason>")
MAPPING = {
    # Field-name validation (RFC 9110 §5.6.2 token/tchar)
    "interop-1-char-special-tchar-name":     ("rfc9110-5.6.2-03-1-char-special-tchar", "RFC 9110 §5.6.2: token = 1*tchar"),
    "interop-all-tchars-header-name":        ("rfc9110-5.6.2-04-all-tchars-field-name", "RFC 9110 §5.6.2: tchar set"),
    "interop-digit-only-header-name":        ("rfc9110-5.6.2-05-digit-only-field-name", "RFC 9110 §5.6.2: DIGIT ∈ tchar"),
    "interop-header-name-uppercase":         ("rfc9110-5.1-01-field-name-case-insensitive", "RFC 9110 §5.1: field names are case-insensitive"),
    "interop-header-name-underscore":        ("rfc9110-5.6.2-06-underscore-field-name", "RFC 9110 §5.6.2: _ ∈ tchar"),

    # Field-value validation (RFC 9110 §5.5 field-vchar/OWS)
    "interop-empty-header-value":            ("rfc9110-5.5-05-empty-field-value", "RFC 9110 §5.5: zero-length field-value allowed"),
    "interop-header-all-ows-value":          ("rfc9110-5.5-06-all-ows-value", "RFC 9110 §5.5: OWS-only value"),
    "interop-header-value-braces":           ("rfc9110-5.5-07-value-with-braces", "RFC 9110 §5.5: VCHAR field-content"),
    "interop-header-value-colons":           ("rfc9110-5.5-08-value-with-colons", "RFC 9110 §5.5: colons inside value"),
    "interop-header-value-equals":           ("rfc9110-5.5-09-value-with-equals", "RFC 9110 §5.5: '=' inside value"),
    "interop-header-value-leading-tab":      ("rfc9110-5.5-10-leading-tab-ows", "RFC 9110 §5.5: OWS includes HTAB"),
    "interop-header-value-parens":           ("rfc9110-5.5-11-value-with-parens", "RFC 9110 §5.5: comment syntax"),
    "interop-header-value-quoted":           ("rfc9110-5.5-12-quoted-value", "RFC 9110 §5.6.4: quoted-string"),
    "interop-header-value-semicolons":       ("rfc9110-5.5-13-value-with-semicolons", "RFC 9110 §5.5: ; inside value"),
    "interop-leading-ows-in-header":         ("rfc9110-5.5-14-extra-leading-ows", "RFC 9110 §5.5: OWS ×N"),
    "interop-many-tabs-after-colon":         ("rfc9110-5.5-15-many-tabs-ows", "RFC 9110 §5.5: OWS ≡ *(SP/HTAB)"),
    "interop-value-starts-with-colon":       ("rfc9110-5.5-16-value-starts-with-colon", "RFC 9110 §5.5: first colon = separator"),
    "interop-whitespace-in-header-value":    ("rfc9110-5.5-17-internal-whitespace", "RFC 9110 §5.5: internal SP/HTAB"),
    "interop-kb-header-value":               ("rfc9110-5.5-18-kb-value", "RFC 9110 §5.5: size tolerance"),
    "interop-no-ows-after-colon":            ("rfc9110-5.5-19-no-ows-after-colon", "RFC 9110 §5.5: OWS is optional"),

    # URI percent-encoding (RFC 3986 §2.1)
    "interop-percent-crlf-in-path":          ("rfc3986-2.1-01-percent-crlf-in-path", "RFC 3986 §2.1: pct-encoded"),
    "interop-percent-encoded-path":          ("rfc3986-2.1-02-percent-encoded-path", "RFC 3986 §2.1: pct-encoded"),
    "interop-percent-encoded-slash":         ("rfc3986-2.1-03-encoded-slash", "RFC 3986 §2.1: %2F"),
    "interop-percent-encoded-unicode":       ("rfc3986-2.1-04-encoded-unicode", "RFC 3986 §2.5: UTF-8 pct-encoded"),
    "interop-percent-null-in-path":          ("rfc3986-2.1-05-percent-null", "RFC 3986 §2.1: %00"),
    "interop-truncated-percent-encoding":    ("rfc3986-2.1-06-truncated-pct-encoding", "RFC 3986 §2.1: % HEXDIG HEXDIG"),
    "interop-invalid-percent-encoding":      ("rfc3986-2.1-07-invalid-pct-encoding", "RFC 3986 §2.1: HEXDIG required"),
    "interop-double-encoded-traversal":      ("rfc3986-6.2.2-01-double-encoded-traversal", "RFC 3986 §6.2.2: decode once"),
    "interop-encoded-dot-dot":               ("rfc3986-6.2.2-02-encoded-dot-dot", "RFC 3986 §6.2.2.2: normalize after decode"),
    "interop-path-encoded-space":            ("rfc3986-2.1-08-encoded-space", "RFC 3986 §2.1: %20"),

    # URI path/segments (RFC 3986 §3.3)
    "interop-deep-path":                     ("rfc3986-3.3-01-deep-path", "RFC 3986 §3.3: multi-segment paths"),
    "interop-double-slash-root":             ("rfc3986-3.3-02-double-slash-root", "RFC 3986 §3.3: path-empty *( / )"),
    "interop-multiple-slashes-in-path":      ("rfc3986-3.3-03-multiple-slashes", "RFC 3986 §3.3: consecutive separators"),
    "interop-path-with-at-sign":             ("rfc3986-3.3-04-path-with-at-sign", "RFC 3986 §3.3: @ ∈ pchar"),
    "interop-path-with-backslash":           ("rfc3986-3.3-05-path-with-backslash", "RFC 3986 §3.3: backslash not in pchar"),
    "interop-path-with-caret":               ("rfc3986-3.3-06-path-with-caret", "RFC 3986 §3.3: ^ not in pchar"),
    "interop-path-with-dot-dot":             ("rfc3986-3.3-07-dot-dot-segment", "RFC 3986 §3.3: dot-segments"),
    "interop-path-with-dot-segment":         ("rfc3986-3.3-08-dot-segment", "RFC 3986 §3.3: ./"),
    "interop-path-with-pipe":                ("rfc3986-3.3-09-path-with-pipe", "RFC 3986 §3.3: | not in pchar"),
    "interop-path-with-semicolon":           ("rfc3986-3.3-10-path-with-semicolon", "RFC 3986 §3.3: ; ∈ sub-delims"),
    "interop-path-with-tilde":               ("rfc3986-3.3-11-path-with-tilde", "RFC 3986 §2.3: ~ ∈ unreserved"),
    "interop-path-curly-braces":             ("rfc3986-3.3-12-curly-braces", "RFC 3986 §3.3: {} not in pchar"),
    "interop-path-special-chars":            ("rfc3986-3.3-13-sub-delims", "RFC 3986 §3.3: sub-delims in pchar"),

    # URI query (RFC 3986 §3.4)
    "interop-empty-query-string":            ("rfc3986-3.4-01-empty-query", "RFC 3986 §3.4: query may be empty"),
    "interop-long-query-string":             ("rfc3986-3.4-02-long-query", "RFC 3986 §3.4: query size tolerance"),
    "interop-huge-query-string":             ("rfc3986-3.4-03-huge-query", "RFC 3986 §3.4: 4KB query"),
    "interop-many-query-params":             ("rfc3986-3.4-04-many-params", "RFC 3986 §3.4: query syntax is application-defined"),
    "interop-plus-in-query":                 ("rfc3986-3.4-05-plus-in-query", "RFC 3986 §3.4: + ∈ sub-delims"),
    "interop-repeated-query-key":            ("rfc3986-3.4-06-repeated-key", "RFC 3986 §3.4: app-defined semantics"),
    "interop-query-string-edges":            ("rfc3986-3.4-07-query-edges", "RFC 3986 §3.4: empty key/value"),
    "interop-url-double-question-mark":      ("rfc3986-3.4-08-double-question-mark", "RFC 3986 §3.4: ? ∈ query"),
    "interop-url-ending-question-mark":      ("rfc3986-3.4-09-trailing-question-mark", "RFC 3986 §3.4: empty query allowed"),

    # Host header / authority (RFC 9112 §3.2.2 + RFC 3986 §3.2.2)
    "interop-host-as-ip":                    ("rfc3986-3.2.2-12-host-as-ipv4", "RFC 3986 §3.2.2: IPv4address"),
    "interop-host-with-port":                ("rfc3986-3.2.2-13-host-with-port", "RFC 3986 §3.2.2: authority [:port]"),
    "interop-host-with-bad-port":            ("rfc3986-3.2.2-14-non-numeric-port", "RFC 3986 §3.2.2: port = *DIGIT"),
    "interop-host-port-zero":                ("rfc3986-3.2.2-15-port-zero", "RFC 3986 §3.2.2: port range"),
    "interop-port-too-large-in-host":        ("rfc3986-3.2.2-16-port-too-large", "RFC 3986 §3.2.2: port ≤ 65535"),
    "interop-host-leading-dot":              ("rfc3986-3.2.2-17-leading-dot-fqdn", "RFC 3986 §3.2.2: reg-name"),
    "interop-host-trailing-dot":             ("rfc3986-3.2.2-18-trailing-dot-fqdn", "RFC 3986 §3.2.2: rooted FQDN"),
    "interop-host-internal-space":           ("rfc3986-3.2.2-19-internal-space", "RFC 3986 §3.2.2: no SP in reg-name"),
    "interop-host-ipv6-literal":             ("rfc3986-3.2.2-20-ipv6-literal", "RFC 3986 §3.2.2: IP-literal [::]"),
    "interop-huge-host-name":                ("rfc3986-3.2.2-21-huge-host-name", "RFC 1035: FQDN length"),
    "interop-empty-host-value":              ("rfc9112-3.2-09-empty-host-value", "RFC 9112 §3.2: Host required"),
    "interop-idn-host":                      ("rfc5891-4-01-idn-a-label", "RFC 5891: IDN A-label (punycode)"),

    # Request-target (RFC 9112 §3.2)
    "interop-absolute-form-target":          ("rfc9112-3.2.2-03-absolute-form", "RFC 9112 §3.2.2: absolute-form"),
    "interop-uri-only-query":                ("rfc9112-3.2.1-01-no-leading-slash", "RFC 9112 §3.2.1: origin-form starts with /"),
    "interop-get-with-fragment":             ("rfc9110-7.1-01-fragment-in-target", "RFC 9110 §7.1: fragments not allowed in request"),

    # Methods (RFC 9110 §9)
    "interop-delete-method":                 ("rfc9110-9.3.5-01-delete-method", "RFC 9110 §9.3.5: DELETE"),
    "interop-delete-with-body":              ("rfc9110-9.3.5-02-delete-with-body", "RFC 9110 §9.3.5: no defined body semantics"),
    "interop-patch-with-body":               ("rfc5789-2-01-patch-method", "RFC 5789 §2: PATCH"),
    "interop-post-empty-body":               ("rfc9110-9.3.3-01-post-empty-body", "RFC 9110 §9.3.3: POST with no body"),
    "interop-put-with-body":                 ("rfc9110-9.3.4-01-put-with-body", "RFC 9110 §9.3.4: PUT body semantics"),
    "interop-link-method":                   ("rfc9110-9.1-02-link-method", "RFC 9110 §9.1: extension methods"),
    "interop-long-method-name":              ("rfc9110-9.1-03-multi-char-method", "RFC 9110 §9.1: method as token"),
    "interop-method-with-digits":            ("rfc9110-9.1-04-method-with-digits", "RFC 9110 §9.1: DIGIT ∈ token"),
    "interop-webdav-copy":                   ("rfc4918-9.8-01-copy-method", "RFC 4918 §9.8: COPY (WebDAV)"),
    "interop-method-mixed-case":             ("rfc9110-9.1-05-method-case-sensitive", "RFC 9110 §9.1: method case-sensitive"),
    "interop-lowercase-method":              ("rfc9110-9.1-06-lowercase-method", "RFC 9110 §9.1: method case-sensitive"),

    # HEAD / OPTIONS / TRACE / CONNECT specifics
    "interop-head-get-ct-parity":            ("rfc9110-9.3.2-03-head-ct-parity", "RFC 9110 §9.3.2: HEAD shares GET headers"),
    "interop-head-get-server-parity":        ("rfc9110-9.3.2-04-head-server-parity", "RFC 9110 §9.3.2: HEAD shares GET headers"),
    "interop-head-get-status-parity":        ("rfc9110-9.3.2-05-head-status-parity", "RFC 9110 §9.3.2: HEAD shares GET status"),
    "interop-head-with-cl":                  ("rfc9110-9.3.2-06-head-with-cl", "RFC 9110 §9.3.2: HEAD has no body"),
    "interop-head-with-request-body":        ("rfc9110-9.3.2-07-head-with-body", "RFC 9110 §9.3.2: HEAD payload undefined"),

    # Framing - Content-Length (RFC 9110 §8.6)
    "interop-body-longer-than-cl":           ("rfc9110-8.6-07-body-longer-than-cl", "RFC 9110 §8.6: CL is the boundary"),
    "interop-cl-leading-zeros":              ("rfc9110-8.6-08-cl-leading-zeros", "RFC 9110 §8.6: 1*DIGIT"),
    "interop-cl-list-same-value":            ("rfc9110-8.6-09-cl-comma-list", "RFC 9110 §8.6: equal-list normalize"),
    "interop-cl-tab-ows":                    ("rfc9110-8.6-10-cl-tab-ows", "RFC 9110 §8.6: OWS in value"),
    "interop-cl-trailing-space":             ("rfc9110-8.6-11-cl-trailing-space", "RFC 9110 §8.6: trim OWS"),
    "interop-duplicate-cl-same-value":       ("rfc9110-8.6-12-duplicate-cl-same", "RFC 9110 §8.6: same-value duplicates"),
    "interop-no-duplicate-content-length":   ("rfc9110-8.6-13-no-duplicate-cl-resp", "RFC 9110 §8.6: at most one CL in response"),
    "interop-no-te-with-cl":                 ("rfc9112-6.1-08-no-te-with-cl", "RFC 9112 §6.1: TE+CL conflict"),

    # Framing - chunked (RFC 9112 §7)
    "interop-chunked-body-post":             ("rfc9112-7-01-chunked-body", "RFC 9112 §7: chunked transfer-coding"),
    "interop-chunked-extension-empty":       ("rfc9112-7.1.1-01-chunk-ext-empty", "RFC 9112 §7.1.1: chunk-ext"),
    "interop-chunked-lowercase-hex":         ("rfc9112-7.1.1-02-chunk-lowercase-hex", "RFC 9112 §7.1.1: HEXDIG"),
    "interop-chunked-multi-chunk":           ("rfc9112-7-02-multi-chunk", "RFC 9112 §7: multiple chunks"),
    "interop-chunked-uppercase-hex":         ("rfc9112-7.1.1-03-chunk-uppercase-hex", "RFC 9112 §7.1.1: HEXDIG"),
    "interop-chunked-with-extension":        ("rfc9112-7.1.1-04-chunk-ext-value", "RFC 9112 §7.1.1: chunk-ext"),
    "interop-chunked-with-trailer":          ("rfc9112-7.1.2-01-chunk-trailer", "RFC 9112 §7.1.2: trailer-section"),
    "interop-double-te-chunked":             ("rfc9112-6.1-05-double-te-chunked", "RFC 9112 §6.1: TE list merge"),
    "interop-te-identity-only":              ("rfc9112-6.1-06-te-identity", "RFC 9112 §6.1: identity coding"),
    "interop-te-substring-match":            ("rfc9112-6.1-07-te-substring-match", "RFC 9112 §6.1: TE is tokens"),

    # Cookies (RFC 6265)
    "interop-cookie-quoted-value":           ("rfc6265-5.2-01-quoted-cookie-value", "RFC 6265 §5.2: cookie value grammar"),
    "interop-many-cookies-one-header":       ("rfc6265-5.4-01-many-cookies", "RFC 6265 §5.4: cookie list"),
    "interop-two-cookie-headers":            ("rfc6265-5.4-02-two-cookie-headers", "RFC 6265 §5.4: multiple Cookie lines"),
    "interop-with-cookie":                   ("rfc6265-5.4-03-with-cookie", "RFC 6265 §5.4: Cookie header"),

    # Content negotiation (RFC 9110 §12.5)
    "interop-accept-encoding-identity":      ("rfc9110-12.5.3-01-identity", "RFC 9110 §12.5.3: identity coding"),
    "interop-accept-multiple-types":         ("rfc9110-12.5.1-01-multiple-types", "RFC 9110 §12.5.1: Accept list"),
    "interop-accept-star-alone":             ("rfc9110-12.5.1-02-star-alone", "RFC 9110 §12.5.1: media-type grammar"),
    "interop-accept-subparams":              ("rfc9110-12.5.1-03-subparams", "RFC 9110 §12.5.1: media-type parameters"),
    "interop-accept-wildcard":               ("rfc9110-12.5.1-04-wildcard", "RFC 9110 §12.5.1: */*"),
    "interop-accept-with-qvalues":           ("rfc9110-12.5.1-05-qvalues", "RFC 9110 §12.5.1: weight"),
    "interop-accept-zero-qvalue":            ("rfc9110-12.5.1-06-zero-qvalue", "RFC 9110 §12.5.1: q=0"),
    "interop-brotli-accept-encoding":        ("rfc9110-12.5.3-02-brotli", "RFC 9110 §12.5.3: br coding"),
    "interop-empty-accept-encoding":         ("rfc9110-12.5.3-03-empty-ae", "RFC 9110 §12.5.3: empty = identity"),
    "interop-multi-accept-encoding":         ("rfc9110-12.5.3-04-multi-ae", "RFC 9110 §12.5.3: list of codings"),
    "interop-multiple-accept-lines":         ("rfc9110-5.3-01-multiple-list-lines", "RFC 9110 §5.3: list-merge equivalence"),
    "interop-with-accept-charset":           ("rfc9110-12.5.2-01-accept-charset", "RFC 9110 §12.5.2: Accept-Charset"),
    "interop-with-accept-language":          ("rfc9110-12.5.4-01-accept-language", "RFC 9110 §12.5.4: Accept-Language"),
    "interop-charset-in-content-type":       ("rfc9110-8.3-01-content-type-charset", "RFC 9110 §8.3: Content-Type params"),

    # Conditional requests (RFC 9110 §13)
    "interop-if-modified-since-future":      ("rfc9110-13.1.3-04-ims-future", "RFC 9110 §13.1.3: If-Modified-Since"),
    "interop-if-modified-since-old":         ("rfc9110-13.1.3-05-ims-old", "RFC 9110 §13.1.3: If-Modified-Since"),
    "interop-if-none-match-present":         ("rfc9110-13.1.2-01-if-none-match", "RFC 9110 §13.1.2: If-None-Match"),
    "interop-weak-etag-if-none-match":       ("rfc9110-8.8.3-01-weak-etag", "RFC 9110 §8.8.3: weak ETag"),

    # Range requests (RFC 9110 §14)
    "interop-range-header-handled":          ("rfc9110-14.1-01-range-handled", "RFC 9110 §14.1: Range header"),
    "interop-range-multiple-byteranges":     ("rfc9110-14.1.2-02-multiple-ranges", "RFC 9110 §14.1.2: multipart/byteranges"),
    "interop-range-open-ended":              ("rfc9110-14.1.2-03-open-ended", "RFC 9110 §14.1.2: bytes=N-"),
    "interop-range-suffix":                  ("rfc9110-14.1.2-04-suffix-range", "RFC 9110 §14.1.2: bytes=-N"),

    # Authorization (RFC 9110 §11)
    "interop-digest-authorization":          ("rfc7616-3-01-digest-auth", "RFC 7616 §3: Digest authentication"),
    "interop-empty-bearer-token":            ("rfc6750-2-01-empty-bearer", "RFC 6750 §2: Bearer token"),
    "interop-multiple-authorization":        ("rfc9110-11-01-multiple-auth", "RFC 9110 §11: Authorization is singleton"),
    "interop-proxy-authorization":           ("rfc9110-11.7.1-01-proxy-auth", "RFC 9110 §11.7.1: Proxy-Authorization"),
    "interop-with-authorization":            ("rfc9110-11.6.2-01-basic-auth", "RFC 9110 §11.6.2: Basic auth"),

    # Pipelining (RFC 9112 §9.3)
    "interop-five-get-pipeline":             ("rfc9112-9.3-02-five-get-pipeline", "RFC 9112 §9.3: pipelining"),
    "interop-persistent-head-then-get":      ("rfc9112-9.3-03-head-then-get", "RFC 9112 §9.3: persistent connections"),
    "interop-pipeline-post-then-get":        ("rfc9112-9.3-04-post-then-get", "RFC 9112 §9.3: pipelined POST+GET"),
    "interop-post-head-pipeline":            ("rfc9112-9.3-05-post-head", "RFC 9112 §9.3: pipelined POST+HEAD"),
    "interop-three-method-pipeline":         ("rfc9112-9.3-06-three-method-pipeline", "RFC 9112 §9.3: pipelining"),

    # HTTP version (RFC 9112 §2.5)
    "interop-http10-request":                ("rfc9112-2.5-03-http10-request", "RFC 9112 §2.5: HTTP/1.0"),
    "interop-http10-keep-alive":             ("rfc9112-9.1-01-http10-keep-alive", "RFC 9112 §9.1: HTTP/1.0 + keep-alive"),
    "interop-http2-preface":                 ("rfc9112-2.5-04-http2-preface", "RFC 9112 §2.5: rejects HTTP/2 preface"),

    # Connection management (RFC 9112 §9)
    "interop-connection-duplicate-close":    ("rfc9110-7.6.1-04-duplicate-close-token", "RFC 9110 §7.6.1: list dedup"),
    "interop-connection-te-token":           ("rfc9110-7.6.1-05-te-token", "RFC 9110 §7.6.1: hop-by-hop tokens"),
    "interop-connection-upgrade-only":       ("rfc9110-7.6.1-06-upgrade-token", "RFC 9110 §7.6.1: Upgrade-token"),
    "interop-no-duplicate-connection-resp":  ("rfc9110-7.6.1-07-no-dup-resp", "RFC 9110 §7.6.1: singleton response"),
    "interop-keep-alive-header":             ("rfc9110-7.6.1-08-keep-alive-header", "RFC 9110 §7.6.1: legacy Keep-Alive"),

    # Browser/proxy headers (RFC 9110 §7.6.x, §10.x)
    "interop-with-cache-control":            ("rfc9111-5.2-01-cache-control", "RFC 9111 §5.2: Cache-Control"),
    "interop-with-client-date":              ("rfc9110-6.6.1-04-client-date", "RFC 9110 §6.6.1: client Date"),
    "interop-with-dnt":                      ("rfc9110-5.3-02-dnt-header", "RFC 9110 §5.3: legacy DNT header"),
    "interop-with-from-header":              ("rfc9110-10.1.2-01-from-header", "RFC 9110 §10.1.2: From"),
    "interop-with-max-forwards":             ("rfc9110-7.6.2-01-max-forwards", "RFC 9110 §7.6.2: Max-Forwards"),
    "interop-with-origin":                   ("rfc6454-7-01-origin", "RFC 6454 §7: Origin"),
    "interop-with-pragma-no-cache":          ("rfc9111-5.4-02-pragma-no-cache", "RFC 9111 §5.4: Pragma"),
    "interop-with-referer":                  ("rfc9110-10.1.3-01-referer", "RFC 9110 §10.1.3: Referer"),
    "interop-with-sec-fetch":                ("fetch-3.4.6-01-sec-fetch", "Fetch §3.4.6: Sec-Fetch-* metadata"),
    "interop-with-via":                      ("rfc9110-7.6.3-01-via", "RFC 9110 §7.6.3: Via"),
    "interop-with-warning-header":           ("rfc9111-5.5-01-warning-header", "RFC 9111 §5.5: Warning (obsolete)"),
    "interop-with-x-custom-header":          ("rfc9110-16.3.2-01-x-custom", "RFC 9110 §16.3.2: extension fields"),
    "interop-with-x-forwarded-for":          ("rfc7239-1-01-x-forwarded-for", "RFC 7239: forwarded-for"),
    "interop-warning-header":                ("rfc9111-5.5-02-warning-passthrough", "RFC 9111 §5.5: Warning ignored"),
    "interop-pragma-no-cache":               ("rfc9111-5.4-01-pragma-no-cache", "RFC 9111 §5.4: Pragma"),

    # Auth / TLS / CORS / WebSocket
    "interop-cors-preflight":                ("fetch-3.2.6-01-cors-preflight", "Fetch §3.2.6: CORS preflight"),
    "interop-origin-null":                   ("rfc6454-7-02-origin-null", "RFC 6454 §7: 'null' origin"),
    "interop-sec-websocket-upgrade":         ("rfc6455-1.3-01-websocket-handshake", "RFC 6455 §1.3: WebSocket handshake"),
    "interop-forwarded-header":              ("rfc7239-1-02-forwarded", "RFC 7239 §1: Forwarded"),
    "interop-upgrade-insecure-requests":     ("upgrade-insecure-requests-3-01", "W3C Upgrade-Insecure-Requests"),

    # Headers used by browser-tolerance probes (RFC 9110 §16.3.2 extension fields)
    "interop-multiple-content-type":         ("rfc9110-8.3-02-multiple-content-type", "RFC 9110 §8.3: Content-Type is singleton"),
    "interop-duplicate-x-custom-header":     ("rfc9110-5.3-03-duplicate-extension", "RFC 9110 §5.3: list-merge for extensions"),
    "interop-empty-user-agent":              ("rfc9110-10.1.5-01-empty-user-agent", "RFC 9110 §10.1.5: User-Agent optional"),
    "interop-long-user-agent":               ("rfc9110-10.1.5-02-long-user-agent", "RFC 9110 §10.1.5: User-Agent size"),

    # Misc
    "interop-bare-lf-request":               ("rfc9112-2.2-11-bare-lf-request", "RFC 9112 §2.2: CRLF terminator"),
    "interop-bare-cr-in-value":              ("rfc9110-5.5-20-bare-cr-in-value", "RFC 9110 §5.5: field-vchar"),
    "interop-browser-style":                 ("rfc9110-2-01-browser-style", "RFC 9110 §2: typical client request"),
    "interop-cl-with-plus-sign":             ("rfc9110-8.6-14-cl-plus-sign", "RFC 9110 §8.6: 1*DIGIT no +/-"),
    "interop-empty-request-then-close":      ("rfc9112-9.3-07-empty-request", "RFC 9112 §9.3: idle conn close"),
    "interop-expect-100-with-body":          ("rfc9110-10.1.1-03-100-continue", "RFC 9110 §10.1.1: 100 Continue"),
    "interop-extra-ws-request-line":         ("rfc9112-3-06-extra-ws-request-line", "RFC 9112 §3: SP separator"),
    "interop-five-get-pipeline":             ("rfc9112-9.3-02-five-get-pipeline", "RFC 9112 §9.3: pipelining"),
    "interop-get-with-body":                 ("rfc9110-9.3.1-02-get-with-body", "RFC 9110 §9.3.1: GET payload undefined"),
    "interop-get-with-fragment":             ("rfc9110-7.1-01-fragment-in-target", "RFC 9110 §7.1: no fragments in request"),
    "interop-get-with-query":                ("rfc3986-3.4-10-get-with-query", "RFC 3986 §3.4: query handling"),
    "interop-many-headers":                  ("rfc9110-5.3-04-many-headers", "RFC 9110 §5.3: header section size"),
    "interop-minimal-request":               ("rfc9112-2-01-minimal-request", "RFC 9112 §2: minimal HTTP message"),
    "interop-options-with-body":             ("rfc9110-9.3.7-03-options-with-body", "RFC 9110 §9.3.7: OPTIONS body"),
    "interop-pipeline-post-then-get":        ("rfc9112-9.3-04-post-then-get", "RFC 9112 §9.3: pipelined POST+GET"),
    "interop-post-cl-zero-with-body-bytes":  ("rfc9110-9.3.3-02-post-cl-zero-bytes", "RFC 9110 §9.3.3: smuggling shape"),
    "interop-single-char-field-name":        ("rfc9110-5.6.2-07-single-char-name", "RFC 9110 §5.6.2: token = 1*tchar"),
    "interop-te-trailers":                   ("rfc9110-10.1.4-01-te-trailers", "RFC 9110 §10.1.4: TE: trailers"),
    "interop-three-persistent-heads":        ("rfc9112-9.3-08-three-heads", "RFC 9112 §9.3: persistent HEAD"),
    "interop-huge-header-count":             ("rfc9110-5.3-05-many-distinct-headers", "RFC 9110 §5.3: header count"),
    "interop-if-match-star":                 ("rfc9110-13.1.1-01-if-match-star", "RFC 9110 §13.1.1: If-Match *"),
    "interop-if-modified-since":             ("rfc9110-13.1.3-06-ims", "RFC 9110 §13.1.3: If-Modified-Since"),
    "interop-pipeline-order":                ("rfc9112-9.3-09-response-order", "RFC 9112 §9.3: response order"),
}

# Collisions that emerge if multiple keys map to the same new ID — caller must fix.

def determine_new_id(old_id: str) -> tuple[str, str] | None:
    return MAPPING.get(old_id)

def update_file(path: Path) -> bool:
    text = path.read_text()
    changed = False

    # Find current test_id
    m = re.search(r'_test_id: String = "([^"]+)"', text)
    if not m:
        return False
    old_id = m.group(1)

    if old_id.startswith("interop-"):
        result = determine_new_id(old_id)
        if result is None:
            print(f"  NO MAPPING: {old_id}")
            return False
        new_id, rfc_ref = result

        text = text.replace(f'"{old_id}"', f'"{new_id}"', 1)
        changed = True
        print(f"  {old_id}  ->  {new_id}")
    else:
        # Already RFC-prefixed; no rename needed
        pass

    if changed:
        path.write_text(text)
    return changed

def update_reject_spec_file(path: Path) -> bool:
    """RejectSpec files use `one_code("ID", ...)` instead of _test_id."""
    text = path.read_text()
    m = re.search(r'one_code\("([^"]+)"', text)
    if not m:
        return False
    old_id = m.group(1)

    if old_id.startswith("interop-"):
        result = determine_new_id(old_id)
        if result is None:
            print(f"  NO MAPPING (reject): {old_id}")
            return False
        new_id, _ = result
        text = text.replace(f'"{old_id}"', f'"{new_id}"', 1)
        path.write_text(text)
        print(f"  {old_id}  ->  {new_id}")
        return True
    return False

def main():
    tests = Path("tests")
    changed = 0
    for f in sorted(tests.glob("*.pony")):
        if update_file(f):
            changed += 1
        elif update_reject_spec_file(f):
            changed += 1
    print(f"---\n{changed} files updated.")

if __name__ == "__main__":
    main()
