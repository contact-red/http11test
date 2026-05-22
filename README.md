# http11test scoreboard — 2026-05-22T042232Z

9 servers × 248 tests.

**Legend:** P = pass · **F** = fail (bold) · **T** = timeout (server did not respond within deadline) · S = skip (test inapplicable)

## CORE tests

Universal-PASS across the reference 8-server set. Stallion column shows where it stands against the minimum bar.

| Test ID | nginx | apache | caddy | bandit | cowboy | lighttpd | haproxy | hyper | **stallion** |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `interop-1-char-special-tchar-name` | P | P | P | P | P | P | P | P | P |
| `interop-accept-encoding-identity` | P | P | P | P | P | P | P | P | P |
| `interop-accept-multiple-types` | P | P | P | P | P | P | P | P | P |
| `interop-accept-star-alone` | P | P | P | P | P | P | P | P | P |
| `interop-accept-wildcard` | P | P | P | P | P | P | P | P | P |
| `interop-accept-with-qvalues` | P | P | P | P | P | P | P | P | P |
| `interop-accept-zero-qvalue` | P | P | P | P | P | P | P | P | P |
| `interop-all-tchars-header-name` | P | P | P | P | P | P | P | P | P |
| `interop-bare-lf-request` | P | P | P | P | P | P | P | P | **T** |
| `interop-body-longer-than-cl` | P | P | P | P | P | P | P | P | P |
| `interop-brotli-accept-encoding` | P | P | P | P | P | P | P | P | P |
| `interop-browser-style` | P | P | P | P | P | P | P | P | P |
| `interop-charset-in-content-type` | P | P | P | P | P | P | P | P | P |
| `interop-chunked-body-post` | P | P | P | P | P | P | P | P | P |
| `interop-chunked-extension-empty` | P | P | P | P | P | P | P | P | P |
| `interop-chunked-lowercase-hex` | P | P | P | P | P | P | P | P | P |
| `interop-chunked-multi-chunk` | P | P | P | P | P | P | P | P | P |
| `interop-chunked-uppercase-hex` | P | P | P | P | P | P | P | P | P |
| `interop-chunked-with-extension` | P | P | P | P | P | P | P | P | P |
| `interop-chunked-with-trailer` | P | P | P | P | P | P | P | P | P |
| `interop-cl-leading-zeros` | P | P | P | P | P | P | P | P | P |
| `interop-cl-list-same-value` | P | P | P | P | P | P | P | P | P |
| `interop-cl-tab-ows` | P | P | P | P | P | P | P | P | P |
| `interop-cl-trailing-space` | P | P | P | P | P | P | P | P | P |
| `interop-cookie-quoted-value` | P | P | P | P | P | P | P | P | P |
| `interop-cors-preflight` | P | P | P | P | P | P | P | P | P |
| `interop-deep-path` | P | P | P | P | P | P | P | P | P |
| `interop-delete-method` | P | P | P | P | P | P | P | P | P |
| `interop-delete-with-body` | P | P | P | P | P | P | P | P | P |
| `interop-digest-authorization` | P | P | P | P | P | P | P | P | P |
| `interop-digit-only-header-name` | P | P | P | P | P | P | P | P | P |
| `interop-double-encoded-traversal` | P | P | P | P | P | P | P | P | P |
| `interop-double-slash-root` | P | P | P | P | P | P | P | P | P |
| `interop-double-te-chunked` | P | P | P | P | P | P | P | P | P |
| `interop-duplicate-cl-same-value` | P | P | P | P | P | P | P | P | P |
| `interop-duplicate-x-custom-header` | P | P | P | P | P | P | P | P | P |
| `interop-empty-accept-encoding` | P | P | P | P | P | P | P | P | P |
| `interop-empty-bearer-token` | P | P | P | P | P | P | P | P | P |
| `interop-empty-header-value` | P | P | P | P | P | P | P | P | P |
| `interop-empty-host-value` | P | P | P | P | P | P | P | P | P |
| `interop-empty-query-string` | P | P | P | P | P | P | P | P | P |
| `interop-empty-request-then-close` | P | P | P | P | P | P | P | P | P |
| `interop-empty-user-agent` | P | P | P | P | P | P | P | P | P |
| `interop-encoded-dot-dot` | P | P | P | P | P | P | P | P | P |
| `interop-expect-100-with-body` | P | P | P | P | P | P | P | P | P |
| `interop-extra-ws-request-line` | P | P | P | P | P | P | P | P | P |
| `interop-five-get-pipeline` | P | P | P | P | P | P | P | P | P |
| `interop-forwarded-header` | P | P | P | P | P | P | P | P | P |
| `interop-get-with-body` | P | P | P | P | P | P | P | P | P |
| `interop-get-with-fragment` | P | P | P | P | P | P | P | P | P |
| `interop-head-with-cl` | P | P | P | P | P | P | P | P | P |
| `interop-head-with-request-body` | P | P | P | P | P | P | P | P | P |
| `interop-header-all-ows-value` | P | P | P | P | P | P | P | P | P |
| `interop-header-name-underscore` | P | P | P | P | P | P | P | P | P |
| `interop-header-name-uppercase` | P | P | P | P | P | P | P | P | P |
| `interop-header-value-braces` | P | P | P | P | P | P | P | P | P |
| `interop-header-value-colons` | P | P | P | P | P | P | P | P | P |
| `interop-header-value-equals` | P | P | P | P | P | P | P | P | P |
| `interop-header-value-leading-tab` | P | P | P | P | P | P | P | P | P |
| `interop-header-value-parens` | P | P | P | P | P | P | P | P | P |
| `interop-header-value-quoted` | P | P | P | P | P | P | P | P | P |
| `interop-header-value-semicolons` | P | P | P | P | P | P | P | P | P |
| `interop-host-as-ip` | P | P | P | P | P | P | P | P | P |
| `interop-host-ipv6-literal` | P | P | P | P | P | P | P | P | P |
| `interop-host-leading-dot` | P | P | P | P | P | P | P | P | P |
| `interop-host-port-zero` | P | P | P | P | P | P | P | P | P |
| `interop-host-trailing-dot` | P | P | P | P | P | P | P | P | P |
| `interop-host-with-port` | P | P | P | P | P | P | P | P | P |
| `interop-http10-keep-alive` | P | P | P | P | P | P | P | P | P |
| `interop-http10-request` | P | P | P | P | P | P | P | P | P |
| `interop-huge-header-count` | P | P | P | P | P | P | P | P | P |
| `interop-huge-host-name` | P | P | P | P | P | P | P | P | P |
| `interop-huge-query-string` | P | P | P | P | P | P | P | P | P |
| `interop-idn-host` | P | P | P | P | P | P | P | P | P |
| `interop-if-modified-since` | P | P | P | P | P | P | P | P | P |
| `interop-if-modified-since-future` | P | P | P | P | P | P | P | P | P |
| `interop-if-none-match` | P | P | P | P | P | P | P | P | P |
| `interop-invalid-percent-encoding` | P | P | P | P | P | P | P | P | P |
| `interop-kb-header-value` | P | P | P | P | P | P | P | P | P |
| `interop-keep-alive-header` | P | P | P | P | P | P | P | P | P |
| `interop-leading-ows-in-header` | P | P | P | P | P | P | P | P | P |
| `interop-link-method` | P | P | P | P | P | P | P | P | P |
| `interop-long-method-name` | P | P | P | P | P | P | P | P | P |
| `interop-long-query-string` | P | P | P | P | P | P | P | P | P |
| `interop-long-user-agent` | P | P | P | P | P | P | P | P | P |
| `interop-lowercase-method` | P | P | P | P | P | P | P | P | P |
| `interop-many-cookies-one-header` | P | P | P | P | P | P | P | P | P |
| `interop-many-query-params` | P | P | P | P | P | P | P | P | P |
| `interop-many-tabs-after-colon` | P | P | P | P | P | P | P | P | P |
| `interop-minimal-request` | P | P | P | P | P | P | P | P | P |
| `interop-multi-accept-encoding` | P | P | P | P | P | P | P | P | P |
| `interop-multiple-accept-lines` | P | P | P | P | P | P | P | P | P |
| `interop-multiple-authorization` | P | P | P | P | P | P | P | P | P |
| `interop-multiple-content-type` | P | P | P | P | P | P | P | P | P |
| `interop-multiple-slashes-in-path` | P | P | P | P | P | P | P | P | P |
| `interop-no-duplicate-connection-resp` | P | P | P | P | P | P | P | P | P |
| `interop-no-duplicate-content-length` | P | P | P | P | P | P | P | P | P |
| `interop-no-duplicate-date` | P | P | P | P | P | P | P | P | P |
| `interop-no-duplicate-server` | P | P | P | P | P | P | P | P | P |
| `interop-options-with-body` | P | P | P | P | P | P | P | P | P |
| `interop-origin-null` | P | P | P | P | P | P | P | P | P |
| `interop-patch-with-body` | P | P | P | P | P | P | P | P | P |
| `interop-path-encoded-space` | P | P | P | P | P | P | P | P | P |
| `interop-path-special-chars` | P | P | P | P | P | P | P | P | P |
| `interop-path-with-at-sign` | P | P | P | P | P | P | P | P | P |
| `interop-path-with-dot-dot` | P | P | P | P | P | P | P | P | P |
| `interop-path-with-dot-segment` | P | P | P | P | P | P | P | P | P |
| `interop-path-with-semicolon` | P | P | P | P | P | P | P | P | P |
| `interop-path-with-tilde` | P | P | P | P | P | P | P | P | P |
| `interop-percent-crlf-in-path` | P | P | P | P | P | P | P | P | P |
| `interop-percent-encoded-path` | P | P | P | P | P | P | P | P | P |
| `interop-percent-encoded-slash` | P | P | P | P | P | P | P | P | P |
| `interop-percent-encoded-unicode` | P | P | P | P | P | P | P | P | P |
| `interop-percent-null-in-path` | P | P | P | P | P | P | P | P | P |
| `interop-persistent-head-then-get` | P | P | P | P | P | P | P | P | **F** |
| `interop-plus-in-query` | P | P | P | P | P | P | P | P | P |
| `interop-post-cl-zero-with-body-bytes` | P | P | P | P | P | P | P | P | P |
| `interop-post-empty-body` | P | P | P | P | P | P | P | P | P |
| `interop-proxy-authorization` | P | P | P | P | P | P | P | P | P |
| `interop-put-with-body` | P | P | P | P | P | P | P | P | P |
| `interop-query-string` | P | P | P | P | P | P | P | P | P |
| `interop-query-string-edges` | P | P | P | P | P | P | P | P | P |
| `interop-range-header-handled` | P | P | P | P | P | P | P | P | P |
| `interop-range-multiple-byteranges` | P | P | P | P | P | P | P | P | P |
| `interop-range-open-ended` | P | P | P | P | P | P | P | P | P |
| `interop-range-suffix` | P | P | P | P | P | P | P | P | P |
| `interop-repeated-query-key` | P | P | P | P | P | P | P | P | P |
| `interop-single-char-field-name` | P | P | P | P | P | P | P | P | P |
| `interop-te-identity-only` | P | P | P | P | P | P | P | P | P |
| `interop-three-method-pipeline` | P | P | P | P | P | P | P | P | P |
| `interop-truncated-percent-encoding` | P | P | P | P | P | P | P | P | P |
| `interop-two-cookie-headers` | P | P | P | P | P | P | P | P | P |
| `interop-upgrade-insecure-requests` | P | P | P | P | P | P | P | P | P |
| `interop-url-double-question-mark` | P | P | P | P | P | P | P | P | P |
| `interop-url-ending-question-mark` | P | P | P | P | P | P | P | P | P |
| `interop-value-starts-with-colon` | P | P | P | P | P | P | P | P | P |
| `interop-weak-etag-if-none-match` | P | P | P | P | P | P | P | P | P |
| `interop-webdav-copy` | P | P | P | P | P | P | P | P | P |
| `interop-whitespace-in-header-value` | P | P | P | P | P | P | P | P | P |
| `interop-with-accept-charset` | P | P | P | P | P | P | P | P | P |
| `interop-with-accept-language` | P | P | P | P | P | P | P | P | P |
| `interop-with-authorization` | P | P | P | P | P | P | P | P | P |
| `interop-with-cache-control` | P | P | P | P | P | P | P | P | P |
| `interop-with-client-date` | P | P | P | P | P | P | P | P | P |
| `interop-with-cookie` | P | P | P | P | P | P | P | P | P |
| `interop-with-dnt` | P | P | P | P | P | P | P | P | P |
| `interop-with-expect-100` | P | P | P | P | P | P | P | P | P |
| `interop-with-from-header` | P | P | P | P | P | P | P | P | P |
| `interop-with-max-forwards` | P | P | P | P | P | P | P | P | P |
| `interop-with-origin` | P | P | P | P | P | P | P | P | P |
| `interop-with-pragma-no-cache` | P | P | P | P | P | P | P | P | P |
| `interop-with-referer` | P | P | P | P | P | P | P | P | P |
| `interop-with-sec-fetch` | P | P | P | P | P | P | P | P | P |
| `interop-with-te-trailers` | P | P | P | P | P | P | P | P | P |
| `interop-with-via` | P | P | P | P | P | P | P | P | P |
| `interop-with-warning-header` | P | P | P | P | P | P | P | P | P |
| `interop-with-x-custom-header` | P | P | P | P | P | P | P | P | P |
| `interop-with-x-forwarded-for` | P | P | P | P | P | P | P | P | P |
| `rfc9110-10.1.1-02-unknown-expectation` | P | P | P | P | P | P | P | P | P |
| `rfc9110-13.1.1-01-if-match-star` | P | P | P | P | P | P | P | P | P |
| `rfc9110-13.1.3-01-ims-malformed` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.3-01-multi-connection` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-01-compact` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.5-04-obs-text` | P | P | P | P | P | P | P | P | P |
| `rfc9110-5.6.7-02` | P | P | P | P | P | P | P | P | **F** |
| `rfc9110-6.2-04` | P | P | P | P | P | P | P | P | P |
| `rfc9110-6.6.1-01-origin-must-date` | P | P | P | P | P | P | P | P | **F** |
| `rfc9110-6.6.1-02-head` | P | P | P | P | P | P | P | P | **F** |
| `rfc9110-8.3-01-form` | P | P | P | P | P | P | P | S | P |
| `rfc9110-8.6-03` | P | P | P | P | P | P | P | P | **F** |
| `rfc9110-8.6-04-negative-cl` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.6-06-hex-cl` | P | P | P | P | P | P | P | P | P |
| `rfc9110-8.6-09` | P | P | P | P | P | P | P | P | P |
| `rfc9110-9.3.2-01` | P | P | P | P | P | P | P | P | **F** |
| `rfc9110-9.3.2-02-content-type` | P | P | P | P | P | P | P | P | **F** |
| `rfc9110-9.3.2-02-server` | P | P | P | P | P | P | P | P | **F** |
| `rfc9110-9.3.2-02-status` | P | P | P | P | P | P | P | P | **F** |
| `rfc9110-9.3.8-02-trace-with-body` | P | P | P | P | P | P | P | P | P |
| `rfc9112-2.2-03` | P | P | P | P | P | P | P | P | P |
| `rfc9112-2.2-04` | P | P | P | P | P | P | P | P | **F** |
| `rfc9112-2.2-08-multiple-empty-lines` | P | P | P | P | P | P | P | P | P |
| `rfc9112-2.5-02-lowercase-http-name` | P | P | P | P | P | P | P | P | P |
| `rfc9112-3.2.2-06` | P | P | P | P | P | P | P | P | P |
| `rfc9112-4-04-reason-phrase-ascii` | P | P | P | P | P | P | P | P | P |
| `rfc9112-5.1-01` | P | P | P | P | P | P | P | P | **F** |
| `rfc9112-5.1-02-tab-before-colon` | P | P | P | P | P | P | P | P | **F** |
| `rfc9112-5.2-01` | P | P | P | P | P | P | P | P | P |
| `rfc9112-6.1-03-te-before-cl` | P | P | P | P | P | P | P | P | P |
| `rfc9112-6.1-04-cl-before-te` | P | P | P | P | P | P | P | P | P |
| `rfc9112-6.2-01` | P | P | P | P | P | P | P | P | P |
| `rfc9112-6.3-04` | P | P | P | P | P | P | P | P | P |
| `rfc9112-6.3-09` | P | P | P | P | P | P | P | P | P |
| `rfc9112-9.3-01` | P | P | P | P | P | P | P | P | **F** |
| `rfc9112-9.3-01-three` | P | P | P | P | P | P | P | P | P |
| `rfc9112-9.3.2-02` | P | P | P | P | P | P | P | P | P |
| `rfc9112-9.6-05` | P | P | P | P | P | P | P | P | P |

## Divergent tests

Already split across the reference 8 — each is its own dialect decision.

| Test ID | nginx | apache | caddy | bandit | cowboy | lighttpd | haproxy | hyper | **stallion** |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `interop-connection-duplicate-close` | P | P | P | **T** | P | P | P | P | **T** |
| `interop-connection-te-token` | P | P | P | **T** | P | P | P | P | **T** |
| `interop-connection-upgrade-only` | P | P | P | **T** | P | P | P | P | **T** |
| `interop-host-internal-space` | P | P | P | **F** | P | P | P | **F** | **F** |
| `interop-host-with-bad-port` | P | P | **F** | P | P | P | P | **F** | **F** |
| `interop-http2-preface` | P | P | **F** | **T** | **F** | **F** | **T** | **F** | P |
| `interop-many-headers` | P | P | P | **F** | P | P | P | P | P |
| `interop-method-with-digits` | P | P | **F** | **F** | **F** | P | P | **F** | P |
| `interop-pipeline-post-then-get` | P | P | P | P | P | **F** | P | P | P |
| `interop-port-too-large-in-host` | P | P | **F** | P | P | P | P | **F** | **F** |
| `interop-post-head-pipeline` | P | P | P | P | P | **F** | P | P | P |
| `interop-sec-websocket-upgrade` | **T** | P | **T** | **T** | P | P | P | **T** | **T** |
| `interop-te-substring-match` | P | P | P | **F** | P | P | P | P | **F** |
| `interop-uri-only-query` | P | **F** | P | P | P | P | P | P | **F** |
| `rfc3986-3.2.2-01-ipv6-no-brackets` | P | P | **F** | P | P | P | P | **F** | **F** |
| `rfc9110-10.2.4-01-origin-server-header` | P | P | P | **F** | P | P | P | **F** | **F** |
| `rfc9110-5.4-01` | P | P | **F** | P | P | P | P | **F** | P |
| `rfc9110-5.5-01-nul-in-value` | P | P | P | **F** | **F** | P | P | P | **F** |
| `rfc9110-5.5-02-bare-cr-in-value` | P | P | P | **F** | **F** | P | P | P | **F** |
| `rfc9110-5.5-03-del-in-value` | **F** | P | P | **F** | **F** | P | **F** | P | **F** |
| `rfc9110-5.6.1-01-comma-ows` | P | P | P | **T** | P | P | P | P | **T** |
| `rfc9110-5.6.2-01-tchar-field-name` | **F** | P | P | P | **F** | P | P | P | **F** |
| `rfc9110-5.6.2-02-high-bit-field-name` | **F** | P | P | P | **F** | P | P | P | **F** |
| `rfc9110-7.6.1-01-conflicting-connection` | P | P | P | **T** | P | P | P | P | **T** |
| `rfc9110-8.3-01` | P | P | P | P | P | P | P | **F** | P |
| `rfc9110-8.6-05-plus-cl` | P | P | P | P | **F** | P | P | P | P |
| `rfc9110-9.1-01-method-case-sensitive` | P | P | **F** | **F** | **F** | P | P | **F** | P |
| `rfc9110-9.3.6-01-connect-origin` | P | P | **F** | **F** | P | P | P | **F** | **F** |
| `rfc9110-9.3.7-01` | **F** | P | **F** | **F** | **F** | P | **F** | **F** | **F** |
| `rfc9110-9.3.7-02-options-path` | **F** | P | **F** | **F** | **F** | **F** | **F** | **F** | **F** |
| `rfc9110-9.3.8-01` | **F** | P | **F** | **F** | **F** | **F** | **F** | **F** | **F** |
| `rfc9112-2.2-07` | P | P | **F** | **F** | P | **F** | P | P | **F** |
| `rfc9112-2.2-09-double-empty-crlf` | P | P | P | P | P | P | P | **F** | P |
| `rfc9112-2.2-10` | **F** | **F** | P | P | P | P | P | P | **F** |
| `rfc9112-2.5-01-http12` | **F** | **F** | **F** | P | P | P | **F** | P | P |
| `rfc9112-3-02` | **F** | P | **F** | **F** | **F** | P | **F** | **F** | **F** |
| `rfc9112-3-03` | P | P | **F** | P | P | **F** | P | P | **F** |
| `rfc9112-3-04-method-with-space` | P | P | P | P | P | **F** | P | P | P |
| `rfc9112-3-05-tab-method-target` | P | P | P | **F** | P | **F** | **F** | P | P |
| `rfc9112-3.2-06-duplicate` | P | P | P | **F** | P | **F** | **F** | **F** | **F** |
| `rfc9112-3.2-06-missing` | P | P | P | P | P | P | P | **F** | **F** |
| `rfc9112-3.2-07-duplicate-host-same` | P | P | P | **F** | P | **F** | **F** | **F** | **F** |
| `rfc9112-3.2-08-no-host-paired` | P | P | P | P | P | P | P | **F** | **F** |
| `rfc9112-3.2.2-01-host-userinfo` | P | P | P | P | P | P | P | **F** | **F** |
| `rfc9112-3.2.3-01-userinfo-in-target` | P | P | **F** | **F** | P | P | P | **F** | **F** |
| `rfc9112-3.2.4-01-get-star` | P | P | **F** | P | P | P | P | **F** | **F** |
| `rfc9112-3.2.4-02` | **F** | P | P | P | P | P | **F** | P | P |
| `rfc9112-5.2-02` | P | **F** | **F** | **F** | P | **F** | **F** | P | P |
| `rfc9112-6.1-01-chunked-not-last` | P | P | P | **F** | P | P | P | P | **F** |
| `rfc9112-6.1-02-http10-chunked` | P | **F** | **F** | **F** | **F** | P | P | P | **F** |
| `rfc9112-9.6-03-list` | P | P | P | **T** | P | P | P | P | **T** |
| `rfc9112-9.6-04` | P | P | P | **F** | P | P | P | P | **F** |

## Scores

| Server | Pass | Fail | Timeout | Skip |
|---|---:|---:|---:|---:|
| nginx | 237 | 10 | 1 | 0 |
| apache | 243 | 5 | 0 | 0 |
| caddy | 228 | 19 | 1 | 0 |
| bandit | 217 | 23 | 8 | 0 |
| cowboy | 234 | 14 | 0 | 0 |
| lighttpd | 236 | 12 | 0 | 0 |
| haproxy | 236 | 11 | 1 | 0 |
| hyper | 223 | 23 | 1 | 1 |
| stallion | 197 | 43 | 8 | 0 |
