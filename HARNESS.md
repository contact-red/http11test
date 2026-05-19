# Compliance-harness endpoint catalog

The `http11test` test runner targets a small **hobby** application — the compliance harness — running on top of stallion. The harness exists to expose endpoints designed to exercise specific RFC 9110 / RFC 9112 requirements deterministically. Tests reference endpoints by path and rely on the documented behavior.

The harness app's source lives in this repository (planned: `harness/` directory). The test runner does NOT spawn or supervise the harness — it expects a running instance and connects to a URL passed on the command line. This document is the contract: the harness MUST behave as described here for the test suite to produce correct results.

## Conventions

- All harness-controlled paths live under `/h/`. Stallion's own behavior (routing, version negotiation, default 404 for unmapped paths) is separate.
- Methods listed for each endpoint are the only ones the endpoint accepts. Any other method MUST yield `405 Method Not Allowed` with an `Allow` header listing the accepted methods.
- All endpoints SHOULD be hermetic — no global state visible across endpoints, no time-of-day dependence (other than the `Date` and `Last-Modified` headers stallion generates).
- Bodies labeled "fixed" are byte-stable across runs.

## Capability boundary: stallion vs. hobby

| Concern | Owner | Notes |
|---|---|---|
| HTTP wire format (parsing, framing, status lines) | **stallion** | Hobby is a transparent shell for wire-format tests. |
| HTTP version negotiation (`HTTP/1.0` requests, future minor versions, `505` for unsupported) | **stallion** | Tests hit any endpoint; stallion responds. |
| 404 for unmapped paths | **hobby** | Hence `/h/status/404` exists explicitly. Hitting a path outside `/h/` is undefined for tests. |
| Chunked-encoded responses | **stallion**, triggered by hobby | Streaming handlers (no `Content-Length` set) cause stallion to use chunked transfer coding. See `/h/streamed`. |
| Content-Length on fixed-size responses | **stallion**, when hobby sets a known body | All `/h/static/*` endpoints. |
| Conditional request evaluation (`If-Match`, `If-None-Match`, etc.) | **TBD** — framework if stallion provides middleware, otherwise per-endpoint in hobby | Either way, the wire behavior MUST match RFC 9110 §13. |
| Range request handling | Same as conditionals | Per-endpoint at minimum for `/h/static/ranged`. |

## A. Wire-format substrate

For most RFC 9112 tests, *any* valid endpoint suffices — the test exercises stallion's wire handling, not the app behind it. The default target for wire-format tests is `/h/echo`.

## B. Static resources

| Path | Methods | Properties | Test IDs (selection) |
|---|---|---|---|
| `/h/static/text` | GET, HEAD, OPTIONS | Fixed ≈300 B `text/plain` body; strong ETag `"text-v1"`; `Last-Modified` stable; `Content-Length`; `Accept-Ranges: bytes` | rfc9112-4-01; rfc9110-9.3.2-01..03 (HEAD parity); 8.6-07; 9.3.7-01 (OPTIONS) |
| `/h/static/weak` | GET, HEAD | Fixed body; weak ETag `W/"weak-v1"`; no `Last-Modified` | rfc9110-8.8.3-01; 13.1.1-01 (strong comparison fails on W/); 13.1.2-01 (weak comparison succeeds) |
| `/h/static/no-validators` | GET, HEAD | Fixed body; no `ETag`; no `Last-Modified` | rfc9110-13.1.x ignore cases |
| `/h/static/ranged` | GET, HEAD | Deterministic 10 KiB body (byte N = N mod 256); strong ETag; `Accept-Ranges: bytes`; supports `Range` | rfc9110-14.2; 15.3.7 (206); 15.5.17 (416); 13.1.5 (If-Range) |
| `/h/static/no-range` | GET, HEAD | Fixed body; Range explicitly unsupported (no `Accept-Ranges`; serves 200 with full body if `Range` requested) | rfc9110-14.2-01; 13.1.5-03 |
| `/h/streamed` | GET, HEAD | Streaming handler — no `Content-Length` set; stallion emits chunked transfer coding | rfc9112-6.1-01 (chunked parse); 6.1-02 (no double-chunk); 6.1-04; 6.1-11 (no TE in HTTP/1.0 response) |

## C. Method-specific endpoints

| Path | Methods | Behavior | Test IDs (selection) |
|---|---|---|---|
| `/h/echo` | GET, POST, PUT | Echoes request body in response; GET returns canned body | rfc9112-6.1-01 (chunked req); 6.3-04..05 (CL handling); rfc9110-10.1.1 (100-continue) |
| `/h/get-only` | GET | All other methods → `405` with `Allow: GET, HEAD` | rfc9110-9.1-04; 10.2.1-01; 15.5.6-01 |
| `/h/mutable/{key}` | GET, HEAD, PUT, DELETE | Idempotent KV. PUT to new key → `201` + `Location`; PUT to existing → `200` or `204`; DELETE → `204`; GET missing → `404`; validator changes on each successful PUT | rfc9110-9.3.4-01..02; 9.3.5-01; 8.8.1-01 |
| `/h/upgrade-target` | GET, OPTIONS | With `Upgrade: test-protocol` (and `Connection: Upgrade`): `101 Switching Protocols` + matching `Upgrade` + `Connection: Upgrade`. Without: `200` with brief body. Connection is simply dropped after the 101 — test does not need to use the post-switch protocol. | rfc9110-7.8-04, -05, -09, -10, -12 |
| `*` (server-wide `OPTIONS *`) | OPTIONS | Returns server capabilities (`Allow`, `Server`, etc.) | rfc9112-3.2.4-02; rfc9110-9.3.7 |

**TRACE deferred.** A `/h/trace-target` endpoint exercising TRACE (rfc9110-9.3.8-01, -03) is planned for a later pass, not the first one.

## D. Status code triggers

Deterministic endpoints that emit specific status codes, so the test suite can verify response shape per RFC 9110 §15.

| Path | Status | Required headers / body | Test IDs |
|---|---|---|---|
| `/h/status/204` | 204 No Content | No body, no `Content-Length`, no `Transfer-Encoding` | rfc9112-6.1-07; rfc9110-8.6-05; 15.3 |
| `/h/status/301` | 301 | `Location` | rfc9110-15.4.2-01 |
| `/h/status/302` | 302 | `Location` | rfc9110-15.4.3-01 |
| `/h/status/303` | 303 | `Location` | rfc9110-15.4.4 |
| `/h/status/307` | 307 | `Location` | rfc9110-15.4.8-02 |
| `/h/status/308` | 308 | `Location` | rfc9110-15.4.9-01 |
| `/h/status/401` | 401 | `WWW-Authenticate` | rfc9110-11.6.1-01; 15.5.2-01 |
| `/h/status/403` | 403 | error body | rfc9110-15.5-01 |
| `/h/status/404` | 404 | error body | rfc9110-15.5-01 |
| `/h/status/411` | 411 | (returned only when a body is sent without `Content-Length`) | rfc9112-6.3-10 (profile) |
| `/h/status/426` | 426 | `Upgrade` | rfc9110-7.8-07; 15.5.22-01 |
| `/h/status/500` | 500 | error body | rfc9110-15.6-01 |
| `/h/status/501` | 501 | (returned for unknown method/TE per §3-02, §6.1-09) | rfc9112-3-02; 6.1-09 |
| `/h/status/503` | 503 | `Retry-After` | rfc9110-15.5.14-02 |

`505 HTTP Version Not Supported` is emitted by stallion itself for unsupported HTTP versions; no harness endpoint required.

## E. Content negotiation

| Path | Methods | Behavior | Test IDs |
|---|---|---|---|
| `/h/negotiated/greeting` | GET | Supports `text/plain`, `text/html`, `application/json` via `Accept`; emits `Vary: Accept` | rfc9110-12.5.5-02; 12.5.1-02 |
| `/h/negotiated/encoded` | GET | Supports `gzip`, `identity`, `x-gzip` via `Accept-Encoding`; emits `Vary: Accept-Encoding` | rfc9110-8.4.1.3-01; 12.5.3-01 |

## F. Authentication

| Path | Methods | Behavior | Test IDs |
|---|---|---|---|
| `/h/protected` | GET | Without credentials: `401` + `WWW-Authenticate: Basic realm="h"`. With `Authorization: Basic dGVzdDp0ZXN0` (`test:test`): `200` | rfc9110-11.6.1-01; 11.2-01; 11.5-01 |

## G. Timing

| Path | Behavior |
|---|---|
| `/h/slow/{ms}` | Delays response by `{ms}` milliseconds; supports `Connection: close` and keepalive |

## H. Profile discovery

| Path | Behavior |
|---|---|
| `/h/probe` | Returns a JSON document listing the harness profile: which optional behaviors stallion / hobby support (chunked-emit, persistent-default, te-in-head-304, default-authority, etc.). The test runner uses this to auto-populate a profile and skip inapplicable tests. |

## What's intentionally absent

- **CONNECT support** — stallion is origin-only; no proxy/tunnel use case.
- **TRACE support** — deferred to a later pass; `/h/trace-target` not implemented in the first pass.
- **`message/http` payload handling** — niche; not needed for the first conformance pass.
- **Proxy/intermediary behaviors** — stallion is origin-only.
