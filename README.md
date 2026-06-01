# http11test scoreboard — 2026-06-01T194402Z

9 servers × 277 tests.

**Legend:** P = pass · **F** = fail (bold) · **T** = timeout (server did not respond within deadline) · S = skip (test inapplicable)

## CORE tests

Universal-PASS across the reference 8-server set. Stallion column shows where it stands against the minimum bar.

| Test ID | nginx | apache | caddy | bandit | cowboy | lighttpd | haproxy | hyper | **stallion** |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `aws-sigv4-1-01-authorization-header` | P | P | P | P | P | P | P | P | P |
| `client-hints-3-01-sec-ch-ua` | P | P | P | P | P | P | P | P | P |
| `fetch-3.2.6-01-cors-preflight` | P | P | P | P | P | P | P | P | P |
| `fetch-3.4.6-01-sec-fetch` | P | P | P | P | P | P | P | P | P |
| `rfc3986-2.1-01-percent-crlf-in-path` | P | P | P | P | P | P | P | P | P |
| `rfc3986-2.1-02-percent-encoded-path` | P | P | P | P | P | P | P | P | P |
| `rfc3986-2.1-03-encoded-slash` | P | P | P | P | P | P | P | P | P |
| `rfc3986-2.1-04-encoded-unicode` | P | P | P | P | P | P | P | P | P |
| `rfc3986-2.1-05-percent-null` | P | P | P | P | P | P | P | P | P |
| `rfc3986-2.1-06-truncated-pct-encoding` | P | P | P | P | P | P | P | P | P |
| `rfc3986-2.1-07-invalid-pct-encoding` | P | P | P | P | P | P | P | P | P |
| `rfc3986-2.1-08-encoded-space` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.2.2-12-host-as-ipv4` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.2.2-13-host-with-port` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.2.2-15-port-zero` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.2.2-17-leading-dot-fqdn` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.2.2-18-trailing-dot-fqdn` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.2.2-20-ipv6-literal` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.2.2-21-huge-host-name` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-01-deep-path` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-02-double-slash-root` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-03-multiple-slashes` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-04-path-with-at-sign` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-05-path-with-backslash` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-06-path-with-caret` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-07-dot-dot-segment` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-08-dot-segment` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-09-path-with-pipe` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-10-path-with-semicolon` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-11-path-with-tilde` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-12-curly-braces` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-13-sub-delims` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.3-14-reserved-delims-in-path` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.4-01-empty-query` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.4-02-long-query` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.4-03-huge-query` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.4-04-many-params` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.4-05-plus-in-query` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.4-06-repeated-key` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.4-07-query-edges` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.4-08-double-question-mark` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.4-09-trailing-question-mark` | P | P | P | P | P | P | P | P | P |
| `rfc3986-3.4-10-get-with-query` | P | P | P | P | P | P | P | P | P |
| `rfc3986-6.2.2-01-double-encoded-traversal` | P | P | P | P | P | P | P | P | P |
| `rfc3986-6.2.2-02-encoded-dot-dot` | P | P | P | P | P | P | P | P | P |
| `rfc4559-4-01-negotiate-auth` | P | P | P | P | P | P | P | P | P |
| `rfc4918-9.8-01-copy-method` | P | P | P | P | P | P | P | P | P |
| `rfc5789-2-01-patch-method` | P | P | P | P | P | P | P | P | P |
| `rfc5891-4-01-idn-a-label` | P | P | P | P | P | P | P | P | P |
| `rfc6265-4.1.3.2-01-cookie-host-prefix` | P | P | P | P | P | P | P | P | P |
| `rfc6265-5.2-01-quoted-cookie-value` | P | P | P | P | P | P | P | P | P |
| `rfc6265-5.4-01-many-cookies` | P | P | P | P | P | P | P | P | P |
| `rfc6265-5.4-02-two-cookie-headers` | P | P | P | P | P | P | P | P | P |
| `rfc6265-5.4-03-with-cookie` | P | P | P | P | P | P | P | P | P |
| `rfc6454-7-01-origin` | P | P | P | P | P | P | P | P | P |
| `rfc6454-7-02-origin-null` | P | P | P | P | P | P | P | P | P |
| `rfc6750-2-01-empty-bearer` | P | P | P | P | P | P | P | P | P |
| `rfc6750-2.1-01-jwt-bearer` | P | P | P | P | P | P | P | P | P |
| `rfc7239-1-01-x-forwarded-for` | P | P | P | P | P | P | P | P | P |
| `rfc7239-1-02-forwarded` | P | P | P | P | P | P | P | P | P |
| `rfc7616-3-01-digest-auth` | P | P | P | P | P | P | P | P | P |
| `rfc9110-10.1.1-02-unknown-expectation` | P | P | P | P | P | P | P | P | P |
| `rfc9110-10.1.1-03-100-continue` | P | P | P | P | P | P | P | P | P |
| `rfc9110-10.1.1-04-expect-100-get` | P | P | P | P | P | P | P | P | P |
| `rfc9110-10.1.2-01-from-header` | P | P | P | P | P | P | P | P | P |
| `rfc9110-10.1.3-01-referer` | P | P | P | P | P | P | P | P | P |
| `rfc9110-10.1.4-01-te-trailers` | P | P | P | P | P | P | P | P | P |
| `rfc9110-10.1.5-01-empty-user-agent` | P | P | P | P | P | P | P | P | P |
| `rfc9110-10.1.5-02-long-user-agent` | P | P | P | P | P | P | P | P | P |
| `rfc9110-10.2.4-02-no-duplicate-server-resp` | P | P | P | P | P | P | P | P | P |
| `rfc9110-11-01-multiple-auth` | P | P | P | P | P | P | P | P | P |
| `rfc9110-11.6.2-01-basic-auth` | P | P | P | P | P | P | P | P | P |
| `rfc9110-11.7.1-01-proxy-auth` | P | P | P | P | P | P | P | P | P |
| `rfc9110-12.5.1-01-multiple-types` | P | P | P | P | P | P | P | P | P |
| `rfc9110-12.5.1-02-star-alone` | P | P | P | P | P | P | P | P | P |
| `rfc9110-12.5.1-03-subparams` | P | P | P | P | P | P | P | P | P |
| `rfc9110-12.5.1-04-wildcard` | P | P | P | P | P | P | P | P | P |
| `rfc9110-12.5.1-05-qvalues` | P | P | P | P | P | P | P | P | P |
| `rfc9110-12.5.1-06-zero-qvalue` | P | P | P | P | P | P | P | P | P |
| `rfc9110-12.5.2-01-accept-charset` | P | P | P | P | P | P | P | P | P |
| `rfc9110-12.5.3-01-identity` | P | P | P | P | P | P | P | P | P |
| `rfc9110-12.5.3-02-brotli` | P | P | P | P | P | P | P | P | P |
| `rfc9110-12.5.3-03-empty-ae` | P | P | P | P | P | P | P | P | P |
| `rfc9110-12.5.3-04-multi-ae` | P | P | P | P | P | P | P | P | P |
| `rfc9110-12.5.4-01-accept-language` | P | P | P | P | P | P | P | P | P |
| `rfc9110-12.5.5-01-vary-in-request` | P | P | P | P | P | P | P | P | P |
| `rfc9110-13.1.1-01-if-match-star` | P | P | P | P | P | P | P | P | P |
| `rfc9110-13.1.2-01-if-none-match` | P | P | P | P | P | P | P | P | P |
| `rfc9110-13.1.3-01-ims-malformed` | P | P | P | P | P | P | P | P | P |
| `rfc9110-13.1.3-04-ims-future` | P | P | P | P | P | P | P | P | P |
| `rfc9110-13.1.3-06-ims` | P | P | P | P | P | P | P | P | P |
| `rfc9110-14.1-01-range-handled` | P | P | P | P | P | P | P | P | P |
| `rfc9110-14.1.2-02-multiple-ranges` | P | P | P | P | P | P | P | P | P |
| `rfc9110-14.1.2-03-open-ended` | P | P | P | P | P | P | P | P | P |
| `rfc9110-14.1.2-04-suffix-range` | P | P | P | P | P | P | P | P | P |
| `rfc9110-16.3.2-01-x-custom` | P | P | P | P | P | P | P | P | P |
| `rfc9110-2-01-browser-style` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.1-01-field-name-case-insensitive` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.1-02-header-mixed-case` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.3-01-multi-connection` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.3-01-multiple-list-lines` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.3-02-dnt-header` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.3-03-duplicate-extension` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.3-05-many-distinct-headers` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-01-compact` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-04-obs-text` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-05-empty-field-value` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-06-all-ows-value` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-07-value-with-braces` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-08-value-with-colons` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-09-value-with-equals` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-10-leading-tab-ows` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-11-value-with-parens` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-12-quoted-value` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-13-value-with-semicolons` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-14-extra-leading-ows` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-15-many-tabs-ows` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-16-value-starts-with-colon` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-17-internal-whitespace` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-18-kb-value` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.6.1-02-trailing-comma` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.6.2-03-1-char-special-tchar` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.6.2-04-all-tchars-field-name` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.6.2-05-digit-only-field-name` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.6.2-06-underscore-field-name` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.6.2-07-single-char-name` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.6.7-02` | P | P | P | P | P | P | P | P | **F** |
| `rfc9110-6.2-04` | P | P | P | P | P | P | P | P | P |
| `rfc9110-6.6.1-01-origin-must-date` | P | P | P | P | P | P | P | P | **F** |
| `rfc9110-6.6.1-02-head` | P | P | P | P | P | P | P | P | **F** |
| `rfc9110-6.6.1-03-no-duplicate-date-resp` | P | P | P | P | P | P | P | P | P |
| `rfc9110-6.6.1-04-client-date` | P | P | P | P | P | P | P | P | P |
| `rfc9110-6.6.1-05-client-date-in-request` | P | P | P | P | P | P | P | P | P |
| `rfc9110-6.6.2-01-trailer-header` | P | P | P | P | P | P | P | P | P |
| `rfc9110-7.1-01-fragment-in-target` | P | P | P | P | P | P | P | P | P |
| `rfc9110-7.6.1-07-no-dup-resp` | P | P | P | P | P | P | P | P | P |
| `rfc9110-7.6.1-08-keep-alive-header` | P | P | P | P | P | P | P | P | P |
| `rfc9110-7.6.1-09-two-close-lines` | P | P | P | P | P | P | P | P | P |
| `rfc9110-7.6.2-01-max-forwards` | P | P | P | P | P | P | P | P | P |
| `rfc9110-7.6.3-01-via` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.3-01-content-type-charset` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.3-01-form` | P | P | P | P | P | P | P | S | P |
| `rfc9110-8.3-02-multiple-content-type` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.3-03-binary-body` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.6-03` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.6-04-negative-cl` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.6-06-hex-cl` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.6-07-body-longer-than-cl` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.6-08-cl-leading-zeros` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.6-09` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.6-09-cl-comma-list` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.6-10-cl-tab-ows` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.6-11-cl-trailing-space` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.6-12-duplicate-cl-same` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.6-13-no-duplicate-cl-resp` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.8.3-01-weak-etag` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.1-02-link-method` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.1-03-multi-char-method` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.1-06-lowercase-method` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.1-02-get-with-body` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.2-01` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.2-02-content-type` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.2-02-server` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.2-02-status` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.2-06-head-with-cl` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.2-07-head-with-body` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.3-01-post-empty-body` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.3-02-post-cl-zero-bytes` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.4-01-put-with-body` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.5-01-delete-method` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.5-02-delete-with-body` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.7-03-options-with-body` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.8-02-trace-with-body` | P | P | P | P | P | P | P | P | P |
| `rfc9111-5.2-01-cache-control` | P | P | P | P | P | P | P | P | P |
| `rfc9111-5.2-02-multiple-directives` | P | P | P | P | P | P | P | P | P |
| `rfc9111-5.4-02-pragma-no-cache` | P | P | P | P | P | P | P | P | P |
| `rfc9111-5.5-01-warning-header` | P | P | P | P | P | P | P | P | P |
| `rfc9112-2-01-minimal-request` | P | P | P | P | P | P | P | P | P |
| `rfc9112-2.2-03` | P | P | P | P | P | P | P | P | P |
| `rfc9112-2.2-04` | P | P | P | P | P | P | P | P | **F** |
| `rfc9112-2.2-08-multiple-empty-lines` | P | P | P | P | P | P | P | P | P |
| `rfc9112-2.2-11-bare-lf-request` | P | P | P | P | P | P | P | P | **T** |
| `rfc9112-2.5-02-lowercase-http-name` | P | P | P | P | P | P | P | P | P |
| `rfc9112-2.5-03-http10-request` | P | P | P | P | P | P | P | P | P |
| `rfc9112-3-06-extra-ws-request-line` | P | P | P | P | P | P | P | P | P |
| `rfc9112-3.2-09-empty-host-value` | P | P | P | P | P | P | P | P | P |
| `rfc9112-3.2.2-06` | P | P | P | P | P | P | P | P | P |
| `rfc9112-4-04-reason-phrase-ascii` | P | P | P | P | P | P | P | P | P |
| `rfc9112-4-05-status-line-prefix` | P | P | P | P | P | P | P | P | P |
| `rfc9112-5.1-01` | P | P | P | P | P | P | P | P | **F** |
| `rfc9112-5.1-02-tab-before-colon` | P | P | P | P | P | P | P | P | **F** |
| `rfc9112-5.2-01` | P | P | P | P | P | P | P | P | P |
| `rfc9112-6.1-03-te-before-cl` | P | P | P | P | P | P | P | P | P |
| `rfc9112-6.1-04-cl-before-te` | P | P | P | P | P | P | P | P | P |
| `rfc9112-6.1-05-double-te-chunked` | P | P | P | P | P | P | P | P | P |
| `rfc9112-6.1-06-te-identity` | P | P | P | P | P | P | P | P | P |
| `rfc9112-6.2-01` | P | P | P | P | P | P | P | P | P |
| `rfc9112-6.3-04` | P | P | P | P | P | P | P | P | P |
| `rfc9112-6.3-09` | P | P | P | P | P | P | P | P | P |
| `rfc9112-7-01-chunked-body` | P | P | P | P | P | P | P | P | P |
| `rfc9112-7-02-multi-chunk` | P | P | P | P | P | P | P | P | P |
| `rfc9112-7.1.1-01-chunk-ext-empty` | P | P | P | P | P | P | P | P | P |
| `rfc9112-7.1.1-02-chunk-lowercase-hex` | P | P | P | P | P | P | P | P | P |
| `rfc9112-7.1.1-03-chunk-uppercase-hex` | P | P | P | P | P | P | P | P | P |
| `rfc9112-7.1.1-04-chunk-ext-value` | P | P | P | P | P | P | P | P | P |
| `rfc9112-7.1.2-01-chunk-trailer` | P | P | P | P | P | P | P | P | P |
| `rfc9112-9.1-01-http10-keep-alive` | P | P | P | P | P | P | P | P | P |
| `rfc9112-9.3-01-three` | P | P | P | P | P | P | P | P | P |
| `rfc9112-9.3-02-five-get-pipeline` | P | P | P | P | P | P | P | P | P |
| `rfc9112-9.3-03-head-then-get` | P | P | P | P | P | P | P | P | P |
| `rfc9112-9.3-06-three-method-pipeline` | P | P | P | P | P | P | P | P | P |
| `rfc9112-9.3-07-empty-request` | P | P | P | P | P | P | P | P | P |
| `rfc9112-9.3-10-many-pipelined-gets` | P | P | P | P | P | P | P | P | P |
| `rfc9112-9.3.2-02` | P | P | P | P | P | P | P | P | P |
| `rfc9112-9.6-05` | P | P | P | P | P | P | P | P | P |
| `rfc9218-2-01-priority-header` | P | P | P | P | P | P | P | P | P |
| `save-data-1-01-save-data-on` | P | P | P | P | P | P | P | P | P |
| `upgrade-insecure-requests-3-01` | P | P | P | P | P | P | P | P | P |

## Divergent tests

Already split across the reference 8 — each is its own dialect decision.

| Test ID | nginx | apache | caddy | bandit | cowboy | lighttpd | haproxy | hyper | **stallion** |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `rfc3986-3.2.2-01-ipv6-no-brackets` | P | P | **F** | P | P | P | P | **F** | **F** |
| `rfc3986-3.2.2-14-non-numeric-port` | P | P | **F** | P | P | P | P | **F** | **F** |
| `rfc3986-3.2.2-16-port-too-large` | P | P | **F** | P | P | P | P | **F** | **F** |
| `rfc3986-3.2.2-19-internal-space` | P | P | P | **F** | P | P | P | **F** | **F** |
| `rfc3986-3.2.2-22-question-mark-in-host` | P | P | P | **F** | P | P | P | **F** | **F** |
| `rfc6455-1.3-01-websocket-handshake` | **T** | P | **T** | **T** | P | P | P | **T** | **T** |
| `rfc9110-10.2.4-01-origin-server-header` | P | P | P | **F** | P | P | P | **F** | **F** |
| `rfc9110-5.3-04-many-headers` | P | P | P | **F** | P | P | P | P | P |
| `rfc9110-5.4-01` | P | P | **F** | P | P | P | P | **F** | P |
| `rfc9110-5.5-01-nul-in-value` | P | P | P | **F** | **F** | P | P | P | **F** |
| `rfc9110-5.5-02-bare-cr-in-value` | P | P | P | **F** | **F** | P | P | P | **F** |
| `rfc9110-5.5-03-del-in-value` | **F** | P | P | **F** | **F** | P | **F** | P | **F** |
| `rfc9110-5.6.1-01-comma-ows` | P | P | P | **T** | P | P | P | P | **T** |
| `rfc9110-5.6.2-01-tchar-field-name` | **F** | P | P | P | **F** | P | P | P | **F** |
| `rfc9110-5.6.2-02-high-bit-field-name` | **F** | P | P | P | **F** | P | P | P | **F** |
| `rfc9110-7.6.1-01-conflicting-connection` | P | P | P | **T** | P | P | P | P | **T** |
| `rfc9110-7.6.1-04-duplicate-close-token` | P | P | P | **T** | P | P | P | P | **T** |
| `rfc9110-7.6.1-05-te-token` | P | P | P | **T** | P | P | P | P | **T** |
| `rfc9110-7.6.1-06-upgrade-token` | P | P | P | **T** | P | P | P | P | **T** |
| `rfc9110-8.3-01` | P | P | P | P | P | P | P | **F** | P |
| `rfc9110-8.6-05-plus-cl` | P | P | P | P | **F** | P | P | P | P |
| `rfc9110-9.1-01-method-case-sensitive` | P | P | **F** | **F** | **F** | P | P | **F** | P |
| `rfc9110-9.1-04-method-with-digits` | P | P | **F** | **F** | **F** | P | P | **F** | P |
| `rfc9110-9.1-07-very-long-method` | **F** | P | P | **F** | P | P | **F** | **F** | P |
| `rfc9110-9.1-08-all-digit-method` | P | P | **F** | **F** | **F** | P | P | **F** | P |
| `rfc9110-9.1-09-hyphen-in-method` | **F** | P | **F** | **F** | **F** | P | **F** | **F** | P |
| `rfc9110-9.3.6-01-connect-origin` | P | P | **F** | **F** | P | P | P | **F** | **F** |
| `rfc9110-9.3.7-01` | **F** | P | **F** | **F** | **F** | P | **F** | **F** | **F** |
| `rfc9110-9.3.7-02-options-path` | **F** | P | **F** | **F** | **F** | **F** | **F** | **F** | **F** |
| `rfc9110-9.3.8-01` | **F** | P | **F** | **F** | **F** | **F** | **F** | **F** | **F** |
| `rfc9112-2.2-07` | P | P | **F** | **F** | P | **F** | P | P | **F** |
| `rfc9112-2.2-09-double-empty-crlf` | P | P | P | P | P | P | P | **F** | P |
| `rfc9112-2.2-10` | **F** | **F** | P | P | P | P | P | P | **F** |
| `rfc9112-2.5-01-http12` | **F** | **F** | **F** | P | P | P | **F** | P | P |
| `rfc9112-2.5-04-http2-preface` | P | P | **F** | **T** | **F** | **F** | **T** | **F** | P |
| `rfc9112-2.5-05-leading-zero-version` | P | P | P | **F** | P | P | P | P | P |
| `rfc9112-3-02` | **F** | P | **F** | **F** | **F** | P | **F** | **F** | **F** |
| `rfc9112-3-03` | P | P | **F** | P | P | **F** | P | P | **F** |
| `rfc9112-3-04-method-with-space` | P | P | P | P | P | **F** | P | P | P |
| `rfc9112-3-05-tab-method-target` | P | P | P | **F** | P | **F** | **F** | P | P |
| `rfc9112-3-07-empty-method` | P | P | P | P | P | **F** | P | P | P |
| `rfc9112-3.2-06-duplicate` | P | P | P | **F** | P | **F** | **F** | **F** | **F** |
| `rfc9112-3.2-06-missing` | P | P | P | P | P | P | P | **F** | **F** |
| `rfc9112-3.2-07-duplicate-host-same` | P | P | P | **F** | P | **F** | **F** | **F** | **F** |
| `rfc9112-3.2-08-no-host-paired` | P | P | P | P | P | P | P | **F** | **F** |
| `rfc9112-3.2.1-01-no-leading-slash` | P | **F** | P | P | P | P | P | P | **F** |
| `rfc9112-3.2.2-01-host-userinfo` | P | P | P | P | P | P | P | **F** | **F** |
| `rfc9112-3.2.3-01-userinfo-in-target` | P | P | **F** | **F** | P | P | P | **F** | **F** |
| `rfc9112-3.2.4-01-get-star` | P | P | **F** | P | P | P | P | **F** | **F** |
| `rfc9112-3.2.4-02` | **F** | P | P | P | P | P | **F** | P | P |
| `rfc9112-5.2-02` | P | **F** | **F** | **F** | P | **F** | **F** | P | P |
| `rfc9112-6.1-01-chunked-not-last` | P | P | P | **F** | P | P | P | P | **F** |
| `rfc9112-6.1-02-http10-chunked` | P | **F** | **F** | **F** | **F** | P | P | P | **F** |
| `rfc9112-6.1-07-te-substring-match` | P | P | P | **F** | P | P | P | P | **F** |
| `rfc9112-9.3-01` | P | **F** | P | P | P | P | P | P | P |
| `rfc9112-9.3-04-post-then-get` | P | P | P | P | P | **F** | P | P | P |
| `rfc9112-9.3-05-post-head` | P | P | P | P | P | **F** | P | P | P |
| `rfc9112-9.6-03-list` | P | P | P | **T** | P | P | P | P | **T** |
| `rfc9112-9.6-04` | P | P | P | **F** | P | P | P | P | **F** |

## Scores

| Server | Pass | Fail | Timeout | Skip |
|---|---:|---:|---:|---:|
| nginx | 264 | 12 | 1 | 0 |
| apache | 271 | 6 | 0 | 0 |
| caddy | 255 | 21 | 1 | 0 |
| bandit | 241 | 28 | 8 | 0 |
| cowboy | 261 | 16 | 0 | 0 |
| lighttpd | 264 | 13 | 0 | 0 |
| haproxy | 263 | 13 | 1 | 0 |
| hyper | 248 | 27 | 1 | 1 |
| stallion | 232 | 37 | 8 | 0 |
