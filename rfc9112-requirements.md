# RFC 9112 (HTTP/1.1) requirements catalog

Normative requirements extracted from [RFC 9112](https://www.rfc-editor.org/rfc/rfc9112.html) (HTTP/1.1, June 2022), intended as a test catalog for the [stallion](https://github.com/ponylang/stallion) HTTP server.

- **Total requirements:** 132
- **Server-relevant subset:** 104
- **By level:** MUST 62, MUST NOT 21, SHOULD 24, SHOULD NOT 4, MAY 21

## Methodology

A Python parser walks the RFC, tracking the current section heading. Sentences containing RFC 2119 keywords in ALL CAPS (MUST, MUST NOT, SHOULD, SHOULD NOT, MAY, plus their synonyms SHALL / REQUIRED / RECOMMENDED / etc.) are captured as requirements. The strongest keyword in a sentence determines its level: a sentence saying "a server MUST do X, but MAY do Y" is classified as MUST.

Actor role is detected by regex (server, client, sender, recipient, user agent, proxy, intermediary, gateway). This is best-effort. A sentence that mentions "client attributes" as a noun phrase may be incorrectly tagged with the `client` role even though the actor is actually the server. The full requirement text is included on every row so manual review during a first pass is straightforward.

**Server-relevant** is true when at least one role is server-side (server, origin server, recipient, sender, intermediary, gateway) or when no role was confidently detected. False when only client-side roles (client, user agent) appear.

## Caveats and known gaps

- **RFC 9112 only.** Most of HTTP's semantic requirements -- status codes, method properties, the Host header's meaning, valid header names, content negotiation -- live in [RFC 9110](https://www.rfc-editor.org/rfc/rfc9110.html) (HTTP Semantics). Caching lives in [RFC 9111](https://www.rfc-editor.org/rfc/rfc9111.html). For full conformance, sibling catalogs for those RFCs are also needed; 9110 alone is roughly 3x the size of this catalog.
- **Sentence boundaries are approximate.** A single normative sentence may correspond to several test cases, and a single test case may cover multiple sentences. Treat rows as test-area anchors, not 1:1 test cases.
- **Role classifier misfires.** Spot-check the role and `Server-relevant` columns during your first review pass. The full requirement text on every row makes correction fast.

## Suggested workflow

1. Walk the Server-relevant rows below and decide for each: **planned**, **in progress**, **implemented**, **tested**, **waived** (with a documented reason), or **out-of-scope**.
2. Track status by editing this file in-tree, or by mirroring the table into a tracking issue. Either way, the `Test ID` column is stable and meant to be referenced from test code:
   ```
   // Covers rfc9112-3.2-04 -- 400 on missing or duplicate Host
   class iso _TestHostHeader400 is UnitTest
   ```
3. The README sheet of the companion xlsx (if you regenerate it) uses the same Test IDs, so the catalog format is interchangeable.

## Summary by category

| Category | MUST | MUST NOT | SHOULD | SHOULD NOT | MAY | Total |
|---|---:|---:|---:|---:|---:|---:|
| message parsing | 5 | 3 | 2 | 1 | 2 | **13** |
| request line | 16 |  | 3 | 1 | 2 | **22** |
| status line | 1 |  | 1 |  | 2 | **4** |
| header fields | 5 | 1 |  |  |  | **6** |
| message body framing | 14 | 8 | 3 |  | 5 | **30** |
| transfer codings | 3 | 2 | 1 | 1 | 1 | **8** |
| chunked coding | 4 | 1 | 1 |  | 2 | **8** |
| incomplete messages | 1 |  |  |  | 1 | **2** |
| request/response association | 1 | 1 |  |  |  | **2** |
| persistence | 4 | 1 | 1 |  | 1 | **7** |
| pipelining | 1 | 1 | 2 | 1 | 2 | **7** |
| timeouts |  |  | 5 |  | 1 | **6** |
| connection teardown | 3 | 3 | 2 |  |  | **8** |
| TLS | 3 |  | 3 |  | 2 | **8** |
| message/http media types | 1 |  |  |  |  | **1** |
| **Total** | **62** | **21** | **24** | **4** | **21** | **132** |

## Server-relevant requirements

Grouped by stallion subsystem. Edit the `Status` column in place; blank means "not yet triaged".

### message parsing

_10 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-2.2-01` | 2.2 | **MUST** | recipient | A recipient MUST parse an HTTP message as a sequence of octets in an encoding that is a superset of US-ASCII [USASCII]. | planned | property: high-bit octets accepted in headers/path |
| `rfc9112-2.2-02` | 2.2 | **MAY** | recipient | Although the line terminator for the start-line and fields is the sequence CRLF, a recipient MAY recognize a single LF as a line terminator and ignore any preceding CR. | planned | profile: lenient_line_terminator |
| `rfc9112-2.2-03` | 2.2 | **MUST NOT** | sender | A sender MUST NOT generate a bare CR (a CR character not immediately followed by LF) within any protocol elements other than the content. | planned | property on server output: no bare CR outside content |
| `rfc9112-2.2-04` | 2.2 | **MUST** | recipient | A recipient of such a bare CR MUST consider that element to be invalid or replace each bare CR with SP before processing the element or forwarding the message. | planned | reject: bare CR in request line/header → 400 or SP-normalized accept |
| `rfc9112-2.2-07` | 2.2 | **SHOULD** | server | In the interest of robustness, a server that is expecting to receive and parse a request-line SHOULD ignore at least one empty line (CRLF) received prior to the request-line. | planned | accept: leading CRLF before request-line |
| `rfc9112-2.2-08` | 2.2 | **MUST NOT** | sender | A sender MUST NOT send whitespace between the start-line and the first header field. | planned | property on server output: no whitespace between status-line and first header |
| `rfc9112-2.2-09` | 2.2 | **MUST** | recipient | A recipient that receives whitespace between the start-line and the first header field MUST either reject the message as invalid or consume each whitespace-preceded line without further processing of it (i.e., ignore the entire line, along with any subsequent lines preceded by whitespace, until a properly formed header field is received or the header section is terminated). | planned | reject: whitespace-led header line → 400 or compliant skip |
| `rfc9112-2.2-10` | 2.2 | **SHOULD** | server | When a server listening only for HTTP request messages, or processing what appears from the start-line to be an HTTP request message, receives a sequence of octets that does not match the HTTP-message grammar aside from the robustness exceptions listed above, the server SHOULD respond with a 400 (Bad Request) response and close the connection. | planned | reject: garbage bytes → 400 + connection close |
| `rfc9112-2.3-01` | 2.3 | **MUST** | intermediary | Intermediaries that process HTTP messages (i.e., all intermediaries other than those acting as tunnels) MUST send their own HTTP-version in forwarded messages, unless it is purposefully downgraded as a workaround for an upstream issue. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9112-2.3-02` | 2.3 | **MAY** | client, intermediary, server | A server MAY send an HTTP/1.0 response to an HTTP/1.1 request if it is known or suspected that the client incorrectly implements the HTTP specification and is incapable of correctly processing later version responses, such as when a client fails to parse the version number correctly or when an intermediary is known to blindly forward the HTTP-version even when it doesn't conform to the given minor version of the protocol. | waived | intentional fallback for known-broken clients; not a conformance behavior |

### request line

_18 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-3-01` | 3 | **MAY** | recipient | Although the request-line grammar rule requires that each of the component elements be separated by a single SP octet, recipients MAY instead parse on whitespace-delimited word boundaries and, aside from the CRLF terminator, treat any form of whitespace as the SP separator while ignoring preceding or trailing whitespace; such whitespace includes one or more of the following octets: SP, HTAB, VT (%x0B), FF (%x0C), or bare CR. | planned | profile: lenient_request_line_ws |
| `rfc9112-3-02` | 3 | **SHOULD** | server | A server that receives a method longer than any that it implements SHOULD respond with a 501 (Not Implemented) status code. | planned | reject: 16-byte unknown method → 501 |
| `rfc9112-3-03` | 3 | **MUST** | server | A server that receives a request-target longer than any URI it wishes to parse MUST respond with a 414 (URI Too Long) status code (see Section 15.5.15 of [HTTP]). | planned | reject: 64 KiB request-target → 414 |
| `rfc9112-3-04` | 3 | **SHOULD** | recipient, sender | It is RECOMMENDED that all HTTP senders and recipients support, at a minimum, request-line lengths of 8000 octets. | planned | accept: ~7900-octet URI succeeds |
| `rfc9112-3.2-01` | 3.2 | **SHOULD** | recipient | Recipients of an invalid request-line SHOULD respond with either a 400 (Bad Request) error or a 301 (Moved Permanently) redirect with the request-target properly encoded. | planned | reject: malformed request-line → 400 |
| `rfc9112-3.2-02` | 3.2 | **SHOULD NOT** | recipient | A recipient SHOULD NOT attempt to autocorrect and then process the request without a redirect, since the invalid request-line might be deliberately crafted to bypass security filters along the request chain. | planned | covered by 3.2-01 — verify no silent autocorrect |
| `rfc9112-3.2-06` | 3.2 | **MUST** | server | A server MUST respond with a 400 (Bad Request) status code to any HTTP/1.1 request message that lacks a Host header field and to any request message that contains more than one Host header field line or a Host header field with an invalid field value. | planned | three sub-tests: missing Host, duplicate Host, invalid Host value |
| `rfc9112-3.2.1-01` | 3.2.1 | **MUST** | client, origin server, server | When making a request directly to an origin server, other than a CONNECT or server-wide OPTIONS request (as detailed below), a client MUST send only the absolute path and query components of the target URI as the request-target. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9112-3.2.2-01` | 3.2.2 | **MUST** | client, proxy, server | When making a request to a proxy, other than a CONNECT or server-wide OPTIONS request (as detailed below), a client MUST send the target URI in "absolute-form" as the request-target. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9112-3.2.2-02` | 3.2.2 | **MUST** | client, proxy | A client MUST send a Host header field in an HTTP/1.1 request even if the request-target is in the absolute-form, since this allows the Host information to be forwarded through ancient HTTP/1.0 proxies that might not have implemented Host. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9112-3.2.2-03` | 3.2.2 | **MUST** | proxy | When a proxy receives a request with an absolute-form of request-target, the proxy MUST ignore the received Host header field (if any) and instead replace it with the host information of the request-target. | out-of-scope | proxy-only; stallion is origin |
| `rfc9112-3.2.2-04` | 3.2.2 | **MUST** | proxy | A proxy that forwards such a request MUST generate a new Host field value based on the received request-target rather than forward the received Host field value. | out-of-scope | proxy-only; stallion is origin |
| `rfc9112-3.2.2-05` | 3.2.2 | **MUST** | origin server, server | When an origin server receives a request with an absolute-form of request-target, the origin server MUST ignore the received Host header field (if any) and instead use the host information of the request-target. | planned | accept: absolute-form authority wins over (mismatched) Host header |
| `rfc9112-3.2.2-06` | 3.2.2 | **MUST** | client, proxy, server | A server MUST accept the absolute-form in requests even though most HTTP/1.1 clients will only send the absolute-form to a proxy. | planned | accept: absolute-form request-target → 200 |
| `rfc9112-3.2.3-01` | 3.2.3 | **MUST** | client, proxy | When making a CONNECT request to establish a tunnel through one or more proxies, a client MUST send only the host and port of the tunnel destination as the request-target. | out-of-scope | client-only (role classifier misfire); CONNECT not supported by stallion |
| `rfc9112-3.2.4-01` | 3.2.4 | **MUST** | client, server | When a client wishes to request OPTIONS for the server as a whole, as opposed to a specific named resource of that server, the client MUST send only "*" (%x2A) as the request-target. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9112-3.2.4-02` | 3.2.4 | **MUST** | origin server, proxy, server | If a proxy receives an OPTIONS request with an absolute-form of request-target in which the URI has an empty path and no query component, then the last proxy on the request chain MUST send a request-target of "*" when it forwards the request to the indicated origin server. | planned | origin half: server accepts `OPTIONS *` |
| `rfc9112-3.3-01` | 3.3 | **MAY** | server | A server that can uniquely identify an authority from the request context MAY use that identity as a default without this risk. | planned | profile: default_authority |

### status line

_4 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-4-01` | 4 | **MAY** |  | The first line of a response message is the status-line, consisting of the protocol version, a space (SP), the status code, and another space and ending with an OPTIONAL textual phrase describing the status code. | planned | property on every response: status-line matches grammar |
| `rfc9112-4-02` | 4 | **MAY** | recipient | Although the status-line grammar rule requires that each of the component elements be separated by a single SP octet, recipients MAY instead parse on whitespace-delimited word boundaries and, aside from the line terminator, treat any form of whitespace as the SP separator while ignoring preceding or trailing whitespace; such whitespace includes one or more of the following octets: SP, HTAB, VT (%x0B), FF (%x0C), or bare CR. | out-of-scope | recipient of status-line is a client; propose appendix move |
| `rfc9112-4-03` | 4 | **SHOULD** | client, intermediary | A client SHOULD ignore the reason-phrase content because it is not a reliable channel for information (it might be translated for a given locale, overwritten by intermediaries, or discarded when the message is forwarded via other versions of HTTP). | out-of-scope | client-only; propose appendix move |
| `rfc9112-4-04` | 4 | **MUST** | server | A server MUST send the space that separates the status-code from the reason-phrase even when the reason-phrase is absent (i.e., the status-line would end with the space). | waived | requires forcing empty reason-phrase; typically not configurable on a black-box server |

### header fields

_5 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-5.1-01` | 5.1 | **MUST** | server | A server MUST reject, with a response status code of 400 (Bad Request), any received request message that contains whitespace between a header field name and colon. | planned | reject: whitespace before colon → 400 |
| `rfc9112-5.1-02` | 5.1 | **MUST** | proxy | A proxy MUST remove any such whitespace from a response message before forwarding the message downstream. | out-of-scope | proxy-only; stallion is origin |
| `rfc9112-5.2-01` | 5.2 | **MUST NOT** | sender | A sender MUST NOT generate a message that includes line folding (i.e., that has any field line value that contains a match to the obs-fold rule) unless the message is intended for packaging within the "message/http" media type. | planned | property on server output: no obs-fold |
| `rfc9112-5.2-02` | 5.2 | **MUST** | server | A server that receives an obs-fold in a request message that is not within a "message/http" container MUST either reject the message by sending a 400 (Bad Request), preferably with a representation explaining that obsolete line folding is unacceptable, or replace each received obs-fold with one or more SP octets prior to interpreting the field value or forwarding the message downstream. | planned | reject/accept: obs-fold request → 400 or SP-normalized |
| `rfc9112-5.2-03` | 5.2 | **MUST** | gateway, proxy | A proxy or gateway that receives an obs-fold in a response message that is not within a "message/http" container MUST either discard the message and replace it with a 502 (Bad Gateway) response, preferably with a representation explaining that unacceptable line folding was received, or replace each received obs-fold with one or more SP octets prior to interpreting the field value or forwarding the message downstream. | out-of-scope | proxy/gateway-only; stallion is origin |

### message body framing

_25 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-6.1-01` | 6.1 | **MUST** | recipient | A recipient MUST be able to parse the chunked transfer coding (Section 7.1) because it plays a crucial role in framing messages when the content size is not known in advance. | planned | accept: chunked POST → body received correctly |
| `rfc9112-6.1-02` | 6.1 | **MUST NOT** | sender | A sender MUST NOT apply the chunked transfer coding more than once to a message body (i.e., chunking an already chunked message is not allowed). | planned | property on server output: chunked at most once in TE |
| `rfc9112-6.1-03` | 6.1 | **MUST** | sender | If any transfer coding other than chunked is applied to a request's content, the sender MUST apply chunked as the final transfer coding to ensure that the message is properly framed. | planned | profile: sends_te_responses |
| `rfc9112-6.1-04` | 6.1 | **MUST** | sender | If any transfer coding other than chunked is applied to a response's content, the sender MUST either apply chunked as the final transfer coding or terminate the message by closing the connection. | planned | profile: sends_te_responses |
| `rfc9112-6.1-05` | 6.1 | **MAY** | recipient | Any recipient along the request/response chain MAY decode the received transfer coding(s) or apply additional transfer coding(s) to the message body, assuming that corresponding changes are made to the Transfer-Encoding field value. | out-of-scope | intermediary; stallion is origin |
| `rfc9112-6.1-06` | 6.1 | **MAY** | origin server, server | Transfer-Encoding MAY be sent in a response to a HEAD request or in a 304 (Not Modified) response (Section 15.4.5 of [HTTP]) to a GET request, neither of which includes a message body, to indicate that the origin server would have applied a transfer coding to the message body if the request had been an unconditional GET. | planned | profile: sends_te_in_head_or_304 |
| `rfc9112-6.1-07` | 6.1 | **MUST NOT** | server | A server MUST NOT send a Transfer-Encoding header field in any response with a status code of 1xx (Informational) or 204 (No Content). | planned | force 204 response → verify no Transfer-Encoding |
| `rfc9112-6.1-08` | 6.1 | **MUST NOT** | server | A server MUST NOT send a Transfer-Encoding header field in any 2xx (Successful) response to a CONNECT request (Section 9.3.6 of [HTTP]). | out-of-scope | CONNECT not supported by stallion |
| `rfc9112-6.1-09` | 6.1 | **SHOULD** | server | A server that receives a request message with a transfer coding it does not understand SHOULD respond with 501 (Not Implemented). | planned | reject: `Transfer-Encoding: bogus, chunked` → 501 |
| `rfc9112-6.1-10` | 6.1 | **MUST NOT** | client, server | A client MUST NOT send a request containing Transfer-Encoding unless it knows the server will handle HTTP/1.1 requests (or later minor revisions); such knowledge might be in the form of specific user configuration or by remembering the version of a prior received response. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9112-6.1-11` | 6.1 | **MUST NOT** | server | A server MUST NOT send a response containing Transfer-Encoding unless the corresponding request indicates HTTP/1.1 (or later minor revisions). | planned | send HTTP/1.0 request → verify response has no Transfer-Encoding |
| `rfc9112-6.1-12` | 6.1 | **MAY** | server | A server MAY reject a request that contains both Content-Length and Transfer-Encoding or process such a request in accordance with the Transfer-Encoding alone. | planned | profile: cl_te_behavior (reject or prefer_te) |
| `rfc9112-6.1-13` | 6.1 | **MUST** | server | Regardless, the server MUST close the connection after responding to such a request to avoid the potential attacks. | planned | send CL+TE → verify connection close after response |
| `rfc9112-6.1-14` | 6.1 | **MUST** | client, server | A server or client that receives an HTTP/1.0 message containing a Transfer-Encoding header field MUST treat the message as if the framing is faulty, even if a Content-Length is present, and close the connection after processing the message. | planned | send HTTP/1.0 + Transfer-Encoding → verify connection close |
| `rfc9112-6.2-01` | 6.2 | **MUST NOT** | sender | A sender MUST NOT send a Content-Length header field in any message that contains a Transfer-Encoding header field. | planned | property on server output: never both CL and TE |
| `rfc9112-6.3-02` | 6.3 | **MUST** | intermediary | An intermediary that chooses to forward the message MUST first remove the received Content-Length field and process the Transfer-Encoding (as described below) prior to forwarding the message downstream. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9112-6.3-03` | 6.3 | **MUST** | server | If a Transfer-Encoding header field is present in a request and the chunked transfer coding is not the final encoding, the message body length cannot be determined reliably; the server MUST respond with the 400 (Bad Request) status code and then close the connection. | planned | reject: `Transfer-Encoding: chunked, gzip` → 400 + close |
| `rfc9112-6.3-04` | 6.3 | **MUST** | recipient | If a message is received without Transfer-Encoding and with an invalid Content-Length header field, then the message framing is invalid and the recipient MUST treat it as an unrecoverable error, unless the field value can be successfully parsed as a comma-separated list (Section 5.6.1 of [HTTP]), all values in the list are valid, and all values in the list are the same (in which case, the message is processed with that single value used as the Content-Length field value). | planned | multiple tests: bad CL forms reject; `5, 5` accept; `5, 6` reject |
| `rfc9112-6.3-05` | 6.3 | **MUST** | server | If the unrecoverable error is in a request message, the server MUST respond with a 400 (Bad Request) status code and then close the connection. | planned | covered by 6.3-04 reject side — 400 + close |
| `rfc9112-6.3-06` | 6.3 | **MUST** | client, gateway, proxy, server | If it is in a response message received by a proxy, the proxy MUST close the connection to the server, discard the received response, and send a 502 (Bad Gateway) response to the client. | out-of-scope | proxy-only; stallion is origin |
| `rfc9112-6.3-07` | 6.3 | **MUST** | server, user agent | If it is in a response message received by a user agent, the user agent MUST close the connection to the server and discard the received response. | out-of-scope | user-agent only (role classifier misfire); propose appendix move |
| `rfc9112-6.3-08` | 6.3 | **MUST** | recipient, sender | If the sender closes the connection or the recipient times out before the indicated number of octets are received, the recipient MUST consider the message to be incomplete and close the connection. | planned | send partial body with CL=N then close; verify server does not reuse keep-alive |
| `rfc9112-6.3-09` | 6.3 | **SHOULD** | server | Since there is no way to distinguish a successfully completed, close-delimited response message from a partially received message interrupted by network failure, a server SHOULD generate encoding or length-delimited messages whenever possible. | planned | property: every non-1xx/204/304/HEAD response has explicit framing |
| `rfc9112-6.3-10` | 6.3 | **MAY** | server | A server MAY reject a request that contains a message body but not a Content-Length by responding with 411 (Length Required). | planned | profile: bodies_require_cl |
| `rfc9112-6.3-13` | 6.3 | **MUST NOT** | client, server | A client MUST NOT use the chunked transfer coding unless it knows the server will handle HTTP/1.1 (or later) requests; such knowledge can be in the form of specific user configuration or by remembering the version of a prior received response. | out-of-scope | client-only (role classifier misfire); propose appendix move |

### transfer codings

_7 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-7.2-01` | 7.2 | **SHOULD** |  | The presence of parameters with any of these compression codings SHOULD be treated as an error. | planned | reject: `Transfer-Encoding: gzip;q=1, chunked` → 501 or 400 |
| `rfc9112-7.3-01` | 7.3 | **MUST** |  | Registrations MUST include the following fields: Name, Description, Pointer to specification text. | out-of-scope | IANA registry rule; not a server behavior |
| `rfc9112-7.3-02` | 7.3 | **MUST NOT** |  | Names of transfer codings MUST NOT overlap with names of content codings (Section 8.4.1 of [HTTP]) unless the encoding transformation is identical, as is the case for the compression codings defined in Section 7.2. | out-of-scope | IANA registry rule; not a server behavior |
| `rfc9112-7.3-03` | 7.3 | **SHOULD NOT** |  | Future registrations of transfer codings SHOULD NOT define parameters called "q" (case-insensitively) in order to avoid ambiguities. | out-of-scope | IANA registry rule; not a server behavior |
| `rfc9112-7.3-04` | 7.3 | **MUST** |  | Values to be added to this namespace require IETF Review (see Section 4.8 of [RFC8126]) and MUST conform to the purpose of transfer coding defined in this specification. | out-of-scope | IANA registry rule; not a server behavior |
| `rfc9112-7.4-01` | 7.4 | **MUST NOT** | client, recipient | A client MUST NOT send the chunked transfer coding name in TE; chunked is always acceptable for HTTP/1.1 recipients. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9112-7.4-03` | 7.4 | **MUST** | intermediary, sender | Since the TE header field only applies to the immediate connection, a sender of TE MUST also send a "TE" connection option within the Connection header field (Section 7.6.1 of [HTTP]) in order to prevent the TE header field from being forwarded by intermediaries that do not support its semantics. | planned | profile/conditional: only when server emits a `TE:` header (rare for response side) |

### chunked coding

_8 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-7.1-01` | 7.1 | **MAY** |  | The chunked transfer coding wraps content in order to transfer it as a series of chunks, each with its own size indicator, followed by an OPTIONAL trailer section containing trailer fields. | out-of-scope | descriptive prose, not a testable normative requirement |
| `rfc9112-7.1-02` | 7.1 | **MUST** | recipient | A recipient MUST be able to parse and decode the chunked transfer coding. | planned | duplicate of 6.1-01; same test |
| `rfc9112-7.1-03` | 7.1 | **MUST** | recipient | Therefore, recipients MUST anticipate potentially large hexadecimal numerals and prevent parsing errors due to integer conversion overflows or precision loss due to integer representation. | planned | send chunk with very large hex size → verify no overflow (graceful reject or process) |
| `rfc9112-7.1-04` | 7.1 | **SHOULD** |  | Their presence SHOULD be treated as an error. | planned | send chunked with parameters on chunk-ext → verify error |
| `rfc9112-7.1.1-01` | 7.1.1 | **MUST** | recipient | A recipient MUST ignore unrecognized chunk extensions. | planned | accept: chunked with unknown chunk-ext |
| `rfc9112-7.1.2-01` | 7.1.2 | **MAY** | recipient | A recipient that removes the chunked coding from a message MAY selectively retain or discard the received trailer fields. | planned | profile: retains_trailers |
| `rfc9112-7.1.2-02` | 7.1.2 | **MUST** | recipient | A recipient that retains a received trailer field MUST either store/forward the trailer field separately from the received header fields or merge the received trailer field into the header section. | out-of-scope | internal trailer storage; not externally observable |
| `rfc9112-7.1.2-03` | 7.1.2 | **MUST NOT** | recipient | A recipient MUST NOT merge a received trailer field into the header section unless its corresponding header field definition explicitly permits and instructs how the trailer field value can be safely merged. | out-of-scope | internal trailer handling; not externally observable |

### incomplete messages

_1 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-8-01` | 8 | **MAY** | server | A server that receives an incomplete request message, usually due to a canceled request or a triggered timeout exception, MAY send an error response prior to closing the connection. | planned | profile: error_response_before_incomplete_close |

### persistence

_4 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-9.3-01` | 9.3 | **SHOULD** |  | HTTP implementations SHOULD support persistent connections. | planned | accept: two sequential requests over one connection both succeed |
| `rfc9112-9.3-03` | 9.3 | **MUST** | server | A server that does not support persistent connections MUST send the "close" connection option in every response message that does not have a 1xx (Informational) status code. | planned | profile: supports_persistent (only tested if false) |
| `rfc9112-9.3-05` | 9.3 | **MUST** | server | A server MUST read the entire request message body or close the connection after sending its response; otherwise, the remaining data on a persistent connection would be misinterpreted as the next request. | planned | send POST with body; accept either compliant outcome (drain body OR close) |
| `rfc9112-9.3-07` | 9.3 | **MUST NOT** | client, proxy, server | A proxy server MUST NOT maintain a persistent connection with an HTTP/1.0 client (see Appendix C.2.2 for information and discussion of the problems with the Keep-Alive header field implemented by many HTTP/1.0 clients). | out-of-scope | proxy-only; stallion is origin |

### pipelining

_4 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-9.3.2-02` | 9.3.2 | **MUST** | server | A server MAY process a sequence of pipelined requests in parallel if they all have safe methods (Section 9.2.1 of [HTTP]), but it MUST send the corresponding responses in the same order that the requests were received. | planned | pipeline two GETs → verify response order matches request order |
| `rfc9112-9.3.2-04` | 9.3.2 | **MUST NOT** | client, server | When retrying pipelined requests after a failed connection (a connection not explicitly closed by the server in its last complete response), a client MUST NOT pipeline immediately after connection establishment, since the first remaining request in the prior pipeline might have caused an error response that can be lost again if multiple requests are sent on a prematurely closed connection. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9112-9.3.2-06` | 9.3.2 | **MAY** | intermediary, user agent | An intermediary that receives pipelined requests MAY pipeline those requests when forwarding them inbound, since it can rely on the outbound user agent(s) to determine what requests can be safely pipelined. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9112-9.3.2-07` | 9.3.2 | **SHOULD** | intermediary, user agent | If the inbound connection fails before receiving a response, the pipelining intermediary MAY attempt to retry a sequence of requests that have yet to receive a response if the requests all have idempotent methods; otherwise, the pipelining intermediary SHOULD forward any received responses and then close the corresponding outbound connection(s) so that the outbound user agent(s) can recover accordingly. | out-of-scope | intermediary-only; stallion is origin |

### timeouts

_5 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-9.5-01` | 9.5 | **SHOULD** | client, server | A client or server that wishes to time out SHOULD issue a graceful close on the connection. | planned | verify server sends FIN (not RST) on timeout-driven close |
| `rfc9112-9.5-02` | 9.5 | **SHOULD** |  | Implementations SHOULD constantly monitor open connections for a received closure signal and respond to it as appropriate, since prompt closure of both sides of a connection enables allocated system resources to be reclaimed. | waived | internal monitoring; not externally observable as a conformance property |
| `rfc9112-9.5-03` | 9.5 | **MAY** | client, proxy, server | A client, server, or proxy MAY close the transport connection at any time. | out-of-scope | permission, not a requirement |
| `rfc9112-9.5-04` | 9.5 | **SHOULD** | client, server | A server SHOULD sustain persistent connections, when possible, and allow the underlying transport's flow-control mechanisms to resolve temporary overloads rather than terminate connections with the expectation that clients will retry. | planned | keepalive multiple requests over time → connection stays alive |
| `rfc9112-9.5-06` | 9.5 | **SHOULD** | client, server | If the client sees a response that indicates the server does not wish to receive the message body and is closing the connection, the client SHOULD immediately cease transmitting the body and close its side of the connection. | out-of-scope | client-only (role classifier misfire); propose appendix move |

### connection teardown

_7 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-9.6-01` | 9.6 | **SHOULD** | sender | A sender SHOULD send a Connection header field (Section 7.6.1 of [HTTP]) containing the "close" connection option when it intends to close a connection. | planned | property: server response includes `Connection: close` before it closes |
| `rfc9112-9.6-03` | 9.6 | **MUST** | server | A server that receives a "close" connection option MUST initiate closure of the connection (see below) after it sends the final response to the request that contained the "close" connection option. | planned | send `Connection: close` request → verify FIN after response |
| `rfc9112-9.6-04` | 9.6 | **SHOULD** | server | The server SHOULD send a "close" connection option in its final response on that connection. | planned | covered by 9.6-01/9.6-03 test material |
| `rfc9112-9.6-05` | 9.6 | **MUST NOT** | server | The server MUST NOT process any further requests received on that connection. | planned | pipeline two requests; first has `Connection: close` → verify second untouched |
| `rfc9112-9.6-06` | 9.6 | **MUST** | server | A server that sends a "close" connection option MUST initiate closure of the connection (see below) after it sends the response containing the "close" connection option. | planned | duplicate of 9.6-03 from sender side |
| `rfc9112-9.6-07` | 9.6 | **MUST NOT** | server | The server MUST NOT process any further requests received on that connection. | planned | duplicate of 9.6-05; same test |
| `rfc9112-9.6-08` | 9.6 | **MUST** | client, server | A client that receives a "close" connection option MUST cease sending requests on that connection and close the connection after reading the response message containing the "close" connection option; if additional pipelined requests had been sent on the connection, the client SHOULD NOT assume that they will be processed by the server. | out-of-scope | client-only (role classifier misfire); propose appendix move |

### TLS

_5 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-9.7-01` | 9.7 | **MUST** |  | All HTTP data MUST be sent as TLS "application data" but is otherwise treated like a normal connection for HTTP (including potential reuse as a persistent connection). | planned | TLS test: HTTP bytes carried in application_data records (not handshake/alert) |
| `rfc9112-9.8-04` | 9.8 | **MAY** | client, server | Clients that do not expect to receive any more data MAY choose not to wait for the server's closure alert and simply close the connection, thus generating an incomplete close on the server side. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9112-9.8-05` | 9.8 | **SHOULD** | client, server | Servers SHOULD be prepared to receive an incomplete close from the client, since the client can often locate the end of server data. | planned | client closes TCP without TLS close_notify → server handles gracefully |
| `rfc9112-9.8-06` | 9.8 | **MUST** | client, server | Servers MUST attempt to initiate an exchange of closure alerts with the client before closing the connection. | planned | client sends close_notify → verify server responds with close_notify |
| `rfc9112-9.8-07` | 9.8 | **MAY** | client, server | Servers MAY close the connection after sending the closure alert, thus generating an incomplete close on the client side. | planned | verify server may FIN after sending close_notify |

### message/http media types

_1 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9112-10.1-01` | 10.1 | **MUST** | recipient | A recipient of "message/http" data MUST replace any obsolete line folding with one or more SP characters when the message is consumed. | waived | only relevant if stallion handles message/http payloads (unlikely for an origin server) |

## Appendix: client-only requirements

Captured for completeness. If stallion ever ships a client (e.g. via [courier](https://github.com/ponylang/courier)) or sprouts a test-fixture client, these become relevant. Otherwise, skim and ignore.

| Test ID | § | Level | Role(s) | Requirement |
|---|---|---|---|---|
| `rfc9112-2.2-05` | 2.2 | **MUST NOT** | user agent | An HTTP/1.1 user agent MUST NOT preface or follow a request with an extra CRLF. |
| `rfc9112-2.2-06` | 2.2 | **MUST** | user agent | If terminating the request message body with a line-ending is desired, then the user agent MUST count the terminating CRLF octets as part of the message body length. |
| `rfc9112-2.3-03` | 2.3 | **SHOULD NOT** | client | Such protocol downgrades SHOULD NOT be performed unless triggered by specific client attributes, such as when one or more of the request header fields (e.g., User-Agent) uniquely match the values sent by a client known to be in error. |
| `rfc9112-3.2-03` | 3.2 | **MUST** | client | A client MUST send a Host header field (Section 7.2 of [HTTP]) in all HTTP/1.1 request messages. |
| `rfc9112-3.2-04` | 3.2 | **MUST** | client | If the target URI includes an authority component, then a client MUST send a field value for Host that is identical to that authority component, excluding any userinfo subcomponent and its "@" delimiter (Section 4.2 of [HTTP]). |
| `rfc9112-3.2-05` | 3.2 | **MUST** | client | If the authority component is missing or undefined for the target URI, then a client MUST send a Host header field with an empty field value. |
| `rfc9112-3.2.1-02` | 3.2.1 | **MUST** | client | If the target URI's path component is empty, the client MUST send "/" as the path within the origin-form of request-target. |
| `rfc9112-5.2-04` | 5.2 | **MUST** | user agent | A user agent that receives an obs-fold in a response message that is not within a "message/http" container MUST replace each received obs-fold with one or more SP octets prior to interpreting the field value. |
| `rfc9112-6.3-01` | 6.3 | **MUST** | client | A client MUST ignore any Content-Length or Transfer-Encoding header fields received in such a message. |
| `rfc9112-6.3-11` | 6.3 | **SHOULD** | client | Unless a transfer coding other than chunked has been applied, a client that sends a request containing a message body SHOULD use a valid Content-Length header field if the message body length is known in advance, rather than the chunked transfer coding, since some existing services respond to chunked with a 411 (Length Required) status code even though they understand the chunked transfer coding. |
| `rfc9112-6.3-12` | 6.3 | **MUST** | user agent | A user agent that sends a request that contains a message body MUST send either a valid Content-Length header field or use the chunked transfer coding. |
| `rfc9112-6.3-14` | 6.3 | **MAY** | user agent | If the final response to the last request on a connection has been completely received and there remains additional data to read, a user agent MAY discard the remaining data or attempt to determine if that data belongs as part of the prior message body, which might be the case if the prior message's Content-Length value is incorrect. |
| `rfc9112-6.3-15` | 6.3 | **MUST NOT** | client | A client MUST NOT process, cache, or forward such extra data as a separate response, since such behavior would be vulnerable to cache poisoning. |
| `rfc9112-7.4-02` | 7.4 | **MAY** | client | When multiple transfer codings are acceptable, the client MAY rank the codings by preference using a case-insensitive "q" parameter (similar to the qvalues used in content negotiation fields; see Section 12.4.2 of [HTTP]). |
| `rfc9112-8-02` | 8 | **MUST** | client | A client that receives an incomplete response message, which can occur when a connection is closed prematurely or when decoding a supposedly chunked transfer coding fails, MUST record the message as incomplete. |
| `rfc9112-9.2-01` | 9.2 | **MUST** | client | A client that has more than one outstanding request on a connection MUST maintain a list of outstanding requests in the order sent and MUST associate each received response message on that connection to the first outstanding request that has not yet received a final (non-1xx) response. |
| `rfc9112-9.2-02` | 9.2 | **MUST NOT** | client | If a client receives data on a connection that doesn't have outstanding requests, the client MUST NOT consider that data to be a valid response; the client SHOULD close the connection, since message delimitation is now ambiguous, unless the data consists only of one or more CRLF (which can be discarded per Section 2.2). |
| `rfc9112-9.3-02` | 9.3 | **MUST** | client | A client that does not support persistent connections MUST send the "close" connection option in every request message. |
| `rfc9112-9.3-04` | 9.3 | **MAY** | client | A client MAY send additional requests on a persistent connection until it sends or receives a "close" connection option or receives an HTTP/1.0 response without a "keep-alive" connection option. |
| `rfc9112-9.3-06` | 9.3 | **MUST** | client | Likewise, a client MUST read the entire response message body if it intends to reuse the same connection for a subsequent request. |
| `rfc9112-9.3.2-01` | 9.3.2 | **MAY** | client | A client that supports persistent connections MAY "pipeline" its requests (i.e., send multiple requests without waiting for each response). |
| `rfc9112-9.3.2-03` | 9.3.2 | **SHOULD** | client | A client that pipelines requests SHOULD retry unanswered requests if the connection closes before it receives all of the corresponding responses. |
| `rfc9112-9.3.2-05` | 9.3.2 | **SHOULD NOT** | user agent | A user agent SHOULD NOT pipeline requests after a non-idempotent method, until the final response status code for that method has been received, unless the user agent has a means to detect and recover from partial failure conditions involving the pipelined sequence. |
| `rfc9112-9.5-05` | 9.5 | **SHOULD** | client | A client sending a message body SHOULD monitor the network connection for an error response while it is transmitting the request. |
| `rfc9112-9.6-02` | 9.6 | **MUST NOT** | client | A client that sends a "close" connection option MUST NOT send further requests on that connection (after the one containing the "close") and MUST close the connection after reading the final response message corresponding to this request. |
| `rfc9112-9.8-01` | 9.8 | **SHOULD** | client | When encountering an incomplete close, a client SHOULD treat as completed all requests for which it has received either: as much data as specified in the Content-Length header field, or the terminal zero-length chunk (when Transfer-Encoding of chunked is used). |
| `rfc9112-9.8-02` | 9.8 | **SHOULD** | client | A client detecting an incomplete close SHOULD recover gracefully. |
| `rfc9112-9.8-03` | 9.8 | **MUST** | client | Clients MUST send a closure alert before closing the connection. |

---

_Generated from RFC 9112 source. To regenerate, re-run the extractor against the current text at <https://www.rfc-editor.org/rfc/rfc9112.html>._
