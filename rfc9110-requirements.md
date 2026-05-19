# RFC 9110 (HTTP Semantics) requirements catalog

Normative requirements extracted from [RFC 9110](https://www.rfc-editor.org/rfc/rfc9110.html) (HTTP Semantics, June 2022), intended as a test catalog for the [stallion](https://github.com/ponylang/stallion) HTTP server.

This is the sibling catalog to [rfc9112-requirements.md](./rfc9112-requirements.md). RFC 9110 covers version-independent semantics — methods, status codes, header fields, conditional requests, range requests, content negotiation, authentication — while RFC 9112 covers HTTP/1.1-specific wire format. A conformant HTTP/1.1 server has to satisfy both.

- **Total requirements:** 357
- **Server-relevant subset:** 291
- **By level:** MUST 113, MUST NOT 71, SHOULD 80, SHOULD NOT 31, MAY 62

## Methodology

Same pipeline as the RFC 9112 catalog. A Python parser walks the RFC, tracks section headings, captures sentences containing RFC 2119 keywords in ALL CAPS, classifies each by its strongest keyword (MUST > MUST NOT > SHOULD > SHOULD NOT > MAY, with their synonyms REQUIRED / SHALL / RECOMMENDED / NOT RECOMMENDED / OPTIONAL folded in), and detects actor role via regex.

**Server-relevant** is true when at least one server-side role (server, origin server, recipient, sender, intermediary, gateway) appears, or when no role was confidently detected. False when only client-side roles (client, user agent) appear.

Because RFC 9110 is large (over 200 pages of normative prose), the source feeding the extractor is a curated extract of section headings and normative paragraphs — not the full document text. ABNF blocks, examples, prose-only intros, and IANA / extension / appendix material were excluded; the resulting count of 357 should be treated as a strong sample of the conformance surface rather than an exhaustive enumeration. Section 16 (extension procedure) and section 18 (IANA mechanics) are intentionally not covered — those bind specification authors and registry maintainers, not server implementations.

## Caveats and known gaps

- **Not exhaustive.** The catalog covers the conformance-shaped requirements that fall out of sections 2-15 and the normative bits of section 17. Some requirements in sub-bullets and embedded prose lists are likely under-counted; treat any gap you spot as a miss to file rather than evidence the requirement isn't real.
- **Role classifier misfires.** Sentences mentioning "client" or "server" as a *noun* rather than the actor get tagged with that role. Spot-check the role and Server-relevant columns on the first review pass.
- **Sentence boundaries are approximate.** A single normative sentence may correspond to several test cases, and a single test case may cover multiple sentences. Treat rows as test-area anchors, not 1:1 test cases.
- **RFC 9111 (caching) is separate.** If stallion ever grows a shared cache, an rfc9111-requirements.md sibling will be needed.

## Suggested workflow

1. Walk the Server-relevant rows below and decide for each: **planned**, **in progress**, **implemented**, **tested**, **waived** (with a documented reason), or **out-of-scope** (e.g. method that stallion doesn't intend to support).
2. Track status by editing this file in-tree. The `Test ID` column is stable and meant to be referenced from test code:
   ```
   // Covers rfc9110-13.1.1-03 -- If-Match precondition failure
   class iso _TestIfMatchPreconditionFailed is UnitTest
   ```
3. RFC 9110 + RFC 9112 IDs share a scheme: `rfc<num>-<section>-<NN>`. A single Pony test can reference both where the behaviors interlock (e.g. Host header semantics live in 9110, framing requirements live in 9112).

## Summary by category

| Category | MUST | MUST NOT | SHOULD | SHOULD NOT | MAY | Total |
|---|---:|---:|---:|---:|---:|---:|
| conformance | 2 | 2 | 1 |  | 2 | **7** |
| terminology |  | 1 |  |  |  | **1** |
| URIs and origins | 3 | 3 | 2 | 1 | 1 | **10** |
| TLS / authority | 6 | 1 |  |  |  | **7** |
| fields | 11 | 6 | 4 | 3 | 3 | **27** |
| message abstraction | 1 | 2 | 3 |  | 1 | **7** |
| trailer fields | 1 | 2 |  | 1 | 1 | **5** |
| message metadata | 2 | 1 | 2 |  | 2 | **7** |
| routing |  |  | 1 |  |  | **1** |
| Host header | 1 |  | 1 |  |  | **2** |
| misdirected requests | 2 |  |  |  |  | **2** |
| forwarding / proxies | 7 | 7 | 2 | 3 | 8 | **27** |
| Upgrade | 5 | 2 | 1 |  | 4 | **12** |
| representation metadata | 2 |  | 3 | 1 | 2 | **8** |
| Content-Length | 1 | 6 | 2 | 1 |  | **10** |
| Content-Location | 1 | 1 |  |  | 1 | **3** |
| validators (ETag / Last-Modified) | 2 | 2 | 4 |  | 1 | **9** |
| methods | 1 |  | 2 |  | 1 | **4** |
| method properties (safe / idempotent) | 1 | 1 | 1 | 2 |  | **5** |
| method: GET |  |  |  | 2 |  | **2** |
| method: HEAD |  | 1 | 1 | 2 | 1 | **5** |
| method: POST |  |  | 1 |  | 1 | **2** |
| method: PUT | 3 | 1 | 4 |  |  | **8** |
| method: DELETE |  |  | 1 | 2 |  | **3** |
| method: CONNECT | 4 | 1 | 1 |  | 1 | **7** |
| method: OPTIONS | 1 | 1 | 1 |  | 1 | **4** |
| method: TRACE |  | 2 | 2 |  |  | **4** |
| request context fields | 2 | 3 | 2 | 6 | 1 | **14** |
| Expect / 100-continue | 5 | 2 | 2 | 1 | 4 | **14** |
| response context fields | 2 | 1 |  | 1 | 1 | **5** |
| authentication | 4 | 2 |  |  | 2 | **8** |
| content negotiation |  | 4 | 4 |  |  | **8** |
| conditional requests | 17 | 6 | 3 | 1 | 8 | **35** |
| conditional: evaluation | 4 | 1 |  |  |  | **5** |
| range requests | 4 | 2 | 7 | 1 | 4 | **18** |
| status codes | 1 |  | 1 |  |  | **2** |
| status: 1xx | 3 | 1 |  |  | 1 | **5** |
| status: 2xx |  | 1 | 1 |  |  | **2** |
| status: 206 partial content | 9 | 3 | 2 | 1 | 3 | **18** |
| status: 3xx redirects | 1 | 1 | 9 | 1 | 1 | **13** |
| status: 4xx | 4 | 1 | 6 | 1 | 5 | **17** |
| status: 5xx |  |  | 3 |  | 1 | **4** |
| **Total** | **113** | **71** | **80** | **31** | **62** | **357** |

## Server-relevant requirements

Grouped by stallion subsystem. Edit the `Status` column in place; blank means "not yet triaged".

### conformance

_7 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-2.2-01` | 2.2 | **MUST NOT** | sender | A sender MUST NOT generate protocol elements that do not match the grammar defined by the corresponding ABNF rules. | planned | property on server output: ABNF conformance |
| `rfc9110-2.2-02` | 2.2 | **MUST NOT** | sender | Within a given message, a sender MUST NOT generate protocol elements or syntax alternatives that are only allowed to be generated by participants in other roles (i.e., a role that the sender does not have for that message). | out-of-scope | abstract role-discipline rule; not testable in isolation |
| `rfc9110-2.2-03` | 2.2 | **MAY** | recipient | A recipient MAY employ such workarounds while remaining conformant to this protocol if the workarounds are limited to the implementations at fault. | out-of-scope | permission to apply workarounds |
| `rfc9110-2.3-01` | 2.3 | **SHOULD** | recipient | A recipient SHOULD parse a received protocol element defensively, with only marginal expectations that the element will conform to its ABNF grammar and fit within a reasonable buffer size. | planned | covered by aggregate of all reject tests |
| `rfc9110-2.3-02` | 2.3 | **MUST** | recipient | At a minimum, a recipient MUST be able to parse and process protocol element lengths that are at least as long as the values that it generates for those same protocol elements in other messages. | planned | property: server accepts its own emitted lengths back |
| `rfc9110-2.4-01` | 2.4 | **MUST** | recipient, sender | A recipient MUST interpret a received protocol element according to the semantics defined for it by this specification, including extensions to this specification, unless the recipient has determined (through experience or configuration) that the sender incorrectly implements what is implied by those semantics. | out-of-scope | meta-rule covered implicitly by every behavioral test |
| `rfc9110-2.4-02` | 2.4 | **MAY** | recipient | Unless noted otherwise, a recipient MAY attempt to recover a usable protocol element from an invalid construct. | out-of-scope | permission to recover |

### terminology

_1 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-3.3-01` | 3.3 | **MUST NOT** | server, user agent | A server MUST NOT assume that two requests on the same connection are from the same user agent unless the connection is secured and specific to that agent. | waived | internal assumption; not externally observable |

### URIs and origins

_9 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-4.1-01` | 4.1 | **SHOULD** | recipient, sender | It is RECOMMENDED that all senders and recipients support, at a minimum, URIs with lengths of 8000 octets in protocol elements. | planned | accept: 8000-octet URI succeeds (overlaps rfc9112-3-04) |
| `rfc9110-4.2.1-01` | 4.2.1 | **MUST NOT** | sender | A sender MUST NOT generate an "http" URI with an empty host identifier. | planned | property on server output: emitted http URIs have non-empty hosts |
| `rfc9110-4.2.1-02` | 4.2.1 | **MUST** | recipient | A recipient that processes such a URI reference MUST reject it as invalid. | planned | reject: absolute-form http URI with empty host → error |
| `rfc9110-4.2.2-01` | 4.2.2 | **MUST NOT** | sender | A sender MUST NOT generate an "https" URI with an empty host identifier. | planned | property on server output: emitted https URIs have non-empty hosts |
| `rfc9110-4.2.2-02` | 4.2.2 | **MUST** | recipient | A recipient that processes such a URI reference MUST reject it as invalid. | planned | reject: absolute-form https URI with empty host → error |
| `rfc9110-4.2.3-01` | 4.2.3 | **MAY** |  | Two HTTP URIs that are equivalent after normalization (using any method) can be assumed to identify the same resource, and any HTTP component MAY perform normalization. | out-of-scope | permission to normalize |
| `rfc9110-4.2.3-02` | 4.2.3 | **SHOULD NOT** |  | As a result, distinct resources SHOULD NOT be identified by HTTP URIs that are equivalent after normalization. | out-of-scope | resource design choice; not testable as wire behavior |
| `rfc9110-4.2.4-01` | 4.2.4 | **MUST NOT** | sender | A sender MUST NOT generate the userinfo subcomponent (and its "@" delimiter) when an "http" or "https" URI reference is generated within a message as a target URI or field value. | planned | property on server output: no userinfo in emitted URIs |
| `rfc9110-4.2.4-02` | 4.2.4 | **SHOULD** | recipient | Before making use of an "http" or "https" URI reference received from an untrusted source, a recipient SHOULD parse for userinfo and treat its presence as an error. | planned | reject: absolute-form request-target containing userinfo |

### TLS / authority

_1 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-4.3.4-01` | 4.3.4 | **MUST** | client, origin server, server | To establish a secured connection to dereference a URI, a client MUST verify that the service's identity is an acceptable match for the URI's origin server. | planned | TLS test: server's certificate matches the host being requested |

### fields

_26 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-5.1-01` | 5.1 | **MUST** | proxy | A proxy MUST forward unrecognized header fields unless the field name is listed in the Connection header field or the proxy is specifically configured to block, or otherwise transform, such fields. | out-of-scope | proxy-only; stallion is origin |
| `rfc9110-5.1-02` | 5.1 | **SHOULD** | recipient | Other recipients SHOULD ignore unrecognized header and trailer fields. | planned | accept: request with unrecognized X-Random header → success |
| `rfc9110-5.3-01` | 5.3 | **MAY** | recipient | A recipient MAY combine multiple field lines within a field section that have the same field name into one field line, without changing the semantics of the message, by appending each subsequent field line value to the initial field line value in order, separated by a comma (",") and optional whitespace. | out-of-scope | permission to combine same-name fields |
| `rfc9110-5.3-02` | 5.3 | **MUST NOT** | proxy | The order in which field lines with the same name are received is therefore significant to the interpretation of the field value; a proxy MUST NOT change the order of these field line values when forwarding a message. | out-of-scope | proxy-only; stallion is origin |
| `rfc9110-5.3-03` | 5.3 | **MUST NOT** | sender | This means that a sender MUST NOT generate multiple field lines with the same name in a message (whether in the headers or trailers) or append a field line when a field line of the same name already exists in the message, unless that field's definition allows multiple field line values to be recombined as a comma-separated list. | planned | property on server output: no duplicate non-list fields |
| `rfc9110-5.3-04` | 5.3 | **MUST NOT** | server | A server MUST NOT apply a request to the target resource until it receives the entire request header section, since later header field lines might include conditionals, authentication credentials, or deliberately misleading duplicate header fields that could impact request processing. | planned | timing: send partial headers; verify server does not respond until full header section received |
| `rfc9110-5.4-01` | 5.4 | **MUST** | client, server | A server that receives a request header field line, field value, or set of fields larger than it wishes to process MUST respond with an appropriate 4xx (Client Error) status code. | planned | reject: oversize field or value → 4xx (431 likely) |
| `rfc9110-5.5-01` | 5.5 | **MUST** |  | When a specific version of HTTP allows such whitespace to appear in a message, a field parsing implementation MUST exclude such whitespace prior to evaluating the field value. | planned | accept: `Host: \tfoo.com` → whitespace excluded before evaluation |
| `rfc9110-5.5-02` | 5.5 | **SHOULD** |  | Specifications for newly defined fields SHOULD limit their values to visible US-ASCII octets (VCHAR), SP, and HTAB. | out-of-scope | guidance for spec authors of new fields |
| `rfc9110-5.5-03` | 5.5 | **SHOULD** | recipient | A recipient SHOULD treat other allowed octets in field content as opaque data. | planned | accept: high-bit octets in opaque-ish field value → no rejection |
| `rfc9110-5.5-04` | 5.5 | **MUST** | recipient | Field values containing CR, LF, or NUL characters are invalid and dangerous; a recipient of CR, LF, or NUL within a field value MUST either reject the message or replace each of those characters with SP before further processing or forwarding of that message. | planned | reject/normalize: CR/LF/NUL in field value |
| `rfc9110-5.5-05` | 5.5 | **MAY** | recipient | Field values containing other CTL characters are also invalid; however, recipients MAY retain such characters for the sake of robustness when they appear within a safe context. | out-of-scope | permission to retain |
| `rfc9110-5.6.1.1-01` | 5.6.1.1 | **MUST NOT** | sender | In any production that uses the list construct, a sender MUST NOT generate empty list elements. | planned | property on server output: no empty list elements |
| `rfc9110-5.6.1.2-01` | 5.6.1.2 | **MUST** | recipient | A recipient MUST parse and ignore a reasonable number of empty list elements. | planned | accept: `Accept: text/html,,application/json` → empties ignored |
| `rfc9110-5.6.1.2-02` | 5.6.1.2 | **MUST** | recipient | In other words, a recipient MUST accept lists that satisfy the syntax with optional elements. | planned | covered by 5.6.1.2-01 |
| `rfc9110-5.6.3-01` | 5.6.3 | **SHOULD NOT** | sender | A sender SHOULD generate the optional whitespace as a single SP; otherwise, a sender SHOULD NOT generate optional whitespace except as needed to overwrite invalid or unwanted protocol elements during in-place message filtering. | planned | property on server output: OWS at most single SP |
| `rfc9110-5.6.3-02` | 5.6.3 | **SHOULD** | sender | A sender SHOULD generate RWS as a single SP. | planned | property on server output: RWS as single SP |
| `rfc9110-5.6.3-03` | 5.6.3 | **MUST NOT** | sender | A sender MUST NOT generate BWS in messages. | planned | property on server output: no BWS |
| `rfc9110-5.6.3-04` | 5.6.3 | **MUST** | recipient | A recipient MUST parse for such bad whitespace and remove it before interpreting the protocol element. | planned | accept: field value with BWS → parsed and BWS removed |
| `rfc9110-5.6.4-01` | 5.6.4 | **MUST** | recipient | Recipients that process the value of a quoted-string MUST handle a quoted-pair as if it were replaced by the octet following the backslash. | planned | accept: ETag value with quoted-pair (e.g., `If-Match: "a\"b"`) → processed |
| `rfc9110-5.6.4-02` | 5.6.4 | **SHOULD NOT** | sender | A sender SHOULD NOT generate a quoted-pair in a quoted-string except where necessary to quote DQUOTE and backslash octets occurring within that string. | planned | property on server output: quoted-pair only when needed |
| `rfc9110-5.6.4-03` | 5.6.4 | **SHOULD NOT** | sender | A sender SHOULD NOT generate a quoted-pair in a comment except where necessary to quote parentheses ["(" and ")"] and backslash octets occurring within that comment. | planned | property on server output: quoted-pair in comments only when needed |
| `rfc9110-5.6.7-01` | 5.6.7 | **MUST** | recipient | A recipient that parses a timestamp value in an HTTP field MUST accept all three HTTP-date formats. | planned | accept: If-Modified-Since in IMF-fixdate, rfc850, asctime formats |
| `rfc9110-5.6.7-02` | 5.6.7 | **MUST** | sender | When a sender generates a field that contains one or more timestamps defined as HTTP-date, the sender MUST generate those timestamps in the IMF-fixdate format. | planned | property on server output: HTTP-date in IMF-fixdate |
| `rfc9110-5.6.7-03` | 5.6.7 | **MUST NOT** | sender | A sender MUST NOT generate additional whitespace in an HTTP-date beyond that specifically included as SP in the grammar. | planned | property on server output: no extra whitespace in HTTP-date |
| `rfc9110-5.6.7-04` | 5.6.7 | **MUST** | recipient | Recipients of a timestamp value in rfc850-date format, which uses a two-digit year, MUST interpret a timestamp that appears to be more than 50 years in the future as representing the most recent year in the past that had the same last two digits. | planned | accept: rfc850 date with future-looking year → 50-year-rule reinterpretation |

### message abstraction

_5 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-6.2-01` | 6.2 | **SHOULD** | client, server | A client SHOULD send a request version equal to the highest version to which the client is conformant and whose major version is no higher than the highest version supported by the server, if this is known. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9110-6.2-03` | 6.2 | **MAY** | client, server | A client MAY send a lower request version if it is known that the server incorrectly implements the HTTP specification, but only after the client has attempted at least one normal request and determined from the response status code or header fields that the server improperly handles higher request versions. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9110-6.2-04` | 6.2 | **SHOULD** | server | A server SHOULD send a response version equal to the highest version to which the server is conformant that has a major version less than or equal to the one received in the request. | planned | response version matches request major version (HTTP/1.1 to HTTP/1.1; HTTP/1.x to HTTP/1.0) |
| `rfc9110-6.2-05` | 6.2 | **MUST NOT** | server | A server MUST NOT send a version to which it is not conformant. | planned | property on server output: never claims a version stallion doesn't support |
| `rfc9110-6.2-06` | 6.2 | **SHOULD** | recipient | A recipient that receives a message with a major version number that it implements and a minor version number higher than what it implements SHOULD process the message as if it were in the highest minor version within that major version to which the recipient is conformant. | planned | accept: HTTP/1.9 request → processed as HTTP/1.1 |

### trailer fields

_5 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-6.5.1-01` | 6.5.1 | **MUST NOT** | sender | A sender MUST NOT generate a trailer field unless the sender knows the corresponding header field name's definition permits the field to be sent in trailers. | planned | property on server output: only trailer-permitted fields appear in trailers |
| `rfc9110-6.5.1-02` | 6.5.1 | **MUST NOT** | recipient | A recipient MUST NOT merge a trailer field into a header section unless the recipient understands the corresponding header field definition and that definition explicitly permits and defines how trailer field values can be safely merged. | out-of-scope | internal trailer handling; not externally observable |
| `rfc9110-6.5.1-03` | 6.5.1 | **SHOULD NOT** | server, user agent | Because of the potential for trailer fields to be discarded in transit, a server SHOULD NOT generate trailer fields that it believes are necessary for the user agent to receive. | waived | server design choice; not externally testable as conformance |
| `rfc9110-6.5.2-01` | 6.5.2 | **MUST** |  | Trailer fields that might be generated more than once during a message MUST be defined as a list-based field even if each member value is only processed once per field line received. | out-of-scope | spec design rule for trailer field definitions |
| `rfc9110-6.5.2-02` | 6.5.2 | **MAY** | recipient | At the end of a message, a recipient MAY treat the set of received trailer fields as a data structure of name/value pairs, similar to (but separate from) the header fields. | out-of-scope | permission |

### message metadata

_7 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-6.6.1-01` | 6.6.1 | **SHOULD** | sender | A sender that generates a Date header field SHOULD generate its field value as the best available approximation of the date and time of message generation. | planned | verify Date ≈ now within reasonable delta |
| `rfc9110-6.6.1-02` | 6.6.1 | **MUST** | client, origin server, server | An origin server with a clock MUST generate a Date header field in all 2xx (Successful), 3xx (Redirection), and 4xx (Client Error) responses, and MAY generate a Date header field in 1xx (Informational) and 5xx (Server Error) responses. | planned | property: server response in 2xx/3xx/4xx has Date header |
| `rfc9110-6.6.1-03` | 6.6.1 | **MUST NOT** | origin server, server | An origin server without a clock MUST NOT generate a Date header field. | out-of-scope | profile: assume stallion has a clock |
| `rfc9110-6.6.1-04` | 6.6.1 | **MUST** | recipient | A recipient with a clock that receives a response message without a Date header field MUST record the time it was received and append a corresponding Date header field to the message's header section if it is cached or forwarded downstream. | out-of-scope | caching/intermediary recipient behavior |
| `rfc9110-6.6.1-05` | 6.6.1 | **MAY** | recipient | A recipient with a clock that receives a response with an invalid Date header field value MAY replace that value with the time that response was received. | out-of-scope | permission |
| `rfc9110-6.6.1-06` | 6.6.1 | **MAY** | server, user agent | A user agent MAY send a Date header field in a request, though generally will not do so unless it is believed to convey useful information to the server. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9110-6.6.2-01` | 6.6.2 | **SHOULD** | sender | A sender that intends to generate one or more trailer fields in a message SHOULD generate a Trailer header field in the header section of that message to indicate which fields might be present in the trailers. | planned | property on server output: Trailer header appears when trailers used |

### misdirected requests

_2 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-7.4-01` | 7.4 | **MUST** | gateway, origin server, server | Unless the connection is from a trusted gateway, an origin server MUST reject a request if any scheme-specific requirements for the target URI are not met. | planned | covered by 7.4-02 test material |
| `rfc9110-7.4-02` | 7.4 | **MUST** |  | In particular, a request for an "https" resource MUST be rejected unless it has been received over a connection that has been secured via a certificate valid for that target URI's origin. | planned | reject: request for https URI received over plaintext → error |

### forwarding / proxies

_27 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-7.6-01` | 7.6 | **MUST** | intermediary | An intermediary not acting as a tunnel MUST implement the Connection header field and exclude fields from being forwarded that are only intended for the incoming connection. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9110-7.6-02` | 7.6 | **MUST NOT** | intermediary | An intermediary MUST NOT forward a message to itself unless it is protected from an infinite request loop. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9110-7.6.1-01` | 7.6.1 | **MUST** | sender | When a field aside from Connection is used to supply control information for or about the current connection, the sender MUST list the corresponding field name within the Connection header field. | out-of-scope | covered for the only relevant cases by rfc9112-7.4-03 / 7.8-10 |
| `rfc9110-7.6.1-02` | 7.6.1 | **MUST** | intermediary | Intermediaries MUST parse a received Connection header field before a message is forwarded and, for each connection-option in this field, remove any header or trailer field(s) from the message with the same name as the connection-option, and then remove the Connection header field itself. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9110-7.6.1-03` | 7.6.1 | **SHOULD** | intermediary | Intermediaries SHOULD remove or replace fields that are known to require removal before forwarding, whether or not they appear as a connection-option, after applying those fields' semantics. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9110-7.6.1-04` | 7.6.1 | **MUST NOT** | recipient, sender | A sender MUST NOT send a connection option corresponding to a field that is intended for all recipients of the content. | out-of-scope | covered by Upgrade/TE-specific tests; abstract |
| `rfc9110-7.6.2-01` | 7.6.2 | **MUST** | intermediary | Each intermediary that receives a TRACE or OPTIONS request containing a Max-Forwards header field MUST check and update its value prior to forwarding the request. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9110-7.6.2-02` | 7.6.2 | **MUST NOT** | intermediary, recipient | If the received value is zero (0), the intermediary MUST NOT forward the request; instead, the intermediary MUST respond as the final recipient. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9110-7.6.2-03` | 7.6.2 | **MUST** | intermediary, recipient | If the received Max-Forwards value is greater than zero, the intermediary MUST generate an updated Max-Forwards field in the forwarded message with a field value that is the lesser of a) the received value decremented by one (1) or b) the recipient's maximum supported value for Max-Forwards. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9110-7.6.2-04` | 7.6.2 | **MAY** | recipient | A recipient MAY ignore a Max-Forwards header field received with any other request methods. | out-of-scope | permission |
| `rfc9110-7.6.3-01` | 7.6.3 | **MUST** | proxy | A proxy MUST send an appropriate Via header field in each message that it forwards. | out-of-scope | proxy-only; stallion is origin |
| `rfc9110-7.6.3-02` | 7.6.3 | **MUST** | gateway | An HTTP-to-HTTP gateway MUST send an appropriate Via header field in each inbound request message and MAY send a Via header field in forwarded response messages. | out-of-scope | gateway-only; stallion is origin |
| `rfc9110-7.6.3-03` | 7.6.3 | **MAY** | sender | A sender MAY replace the received-by host with a pseudonym if the real host is considered to be sensitive information. | out-of-scope | proxy/intermediary Via behavior |
| `rfc9110-7.6.3-04` | 7.6.3 | **MAY** | recipient | If a port is not provided, a recipient MAY interpret that as meaning it was received on the default port. | out-of-scope | proxy/intermediary Via behavior |
| `rfc9110-7.6.3-05` | 7.6.3 | **MAY** | recipient, sender | A sender MAY generate comments to identify the software of each recipient. | out-of-scope | proxy/intermediary Via behavior |
| `rfc9110-7.6.3-06` | 7.6.3 | **MAY** | recipient | However, comments in Via are optional, and a recipient MAY remove them prior to forwarding the message. | out-of-scope | proxy/intermediary Via behavior |
| `rfc9110-7.6.3-07` | 7.6.3 | **SHOULD NOT** | intermediary | An intermediary used as a portal through a network firewall SHOULD NOT forward the names and ports of hosts within the firewall region unless it is explicitly enabled to do so. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9110-7.6.3-08` | 7.6.3 | **SHOULD** | intermediary | If not enabled, such an intermediary SHOULD replace each received-by host of any host behind the firewall by an appropriate pseudonym for that host. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9110-7.6.3-09` | 7.6.3 | **MAY** | intermediary | An intermediary MAY combine an ordered subsequence of Via header field list members into a single member if the entries have identical received-protocol values. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9110-7.6.3-10` | 7.6.3 | **SHOULD NOT** | sender | A sender SHOULD NOT combine multiple list members unless they are all under the same organizational control and the hosts have already been replaced by pseudonyms. | out-of-scope | intermediary Via behavior |
| `rfc9110-7.6.3-11` | 7.6.3 | **MUST NOT** | sender | A sender MUST NOT combine members that have different received-protocol values. | out-of-scope | intermediary Via behavior |
| `rfc9110-7.7-01` | 7.7 | **MAY** | proxy | If a proxy receives a target URI with a host name that is not a fully qualified domain name, it MAY add its own domain to the host name it received when forwarding the request. | out-of-scope | proxy-only; stallion is origin |
| `rfc9110-7.7-02` | 7.7 | **MUST NOT** | proxy | A proxy MUST NOT change the host name if the target URI contains a fully qualified domain name. | out-of-scope | proxy-only; stallion is origin |
| `rfc9110-7.7-03` | 7.7 | **MUST NOT** | proxy, server | A proxy MUST NOT modify the "absolute-path" and "query" parts of the received target URI when forwarding it to the next inbound server except as required by that forwarding protocol. | out-of-scope | proxy-only; stallion is origin |
| `rfc9110-7.7-04` | 7.7 | **MUST NOT** | proxy | A proxy MUST NOT transform the content of a response message that contains a no-transform cache directive. | out-of-scope | proxy-only; stallion is origin |
| `rfc9110-7.7-05` | 7.7 | **MAY** | proxy | A proxy MAY transform the content of a message that does not contain a no-transform cache directive. | out-of-scope | proxy-only; stallion is origin |
| `rfc9110-7.7-06` | 7.7 | **SHOULD NOT** | proxy | A proxy SHOULD NOT modify header fields that provide information about the endpoints of the communication chain, the resource state, or the selected representation (other than the content) unless the field's definition specifically allows such modification or the modification is deemed necessary for privacy or security. | out-of-scope | proxy-only; stallion is origin |

### Upgrade

_12 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-7.8-01` | 7.8 | **MAY** | client, server | A client MAY send a list of protocol names in the Upgrade header field of a request to invite the server to switch to one or more of the named protocols, in order of descending preference, before sending the final response. | out-of-scope | client-only (sends Upgrade); propose appendix move |
| `rfc9110-7.8-02` | 7.8 | **MAY** | server | A server MAY ignore a received Upgrade header field if it wishes to continue using the current protocol on that connection. | out-of-scope | permission |
| `rfc9110-7.8-03` | 7.8 | **SHOULD** | recipient | Although protocol names are registered with a preferred case, recipients SHOULD use case-insensitive comparison when matching each protocol-name to supported protocols. | planned | conditional on stallion Upgrade support; case-insensitive protocol match |
| `rfc9110-7.8-04` | 7.8 | **MUST** | sender, server | A server that sends a 101 (Switching Protocols) response MUST send an Upgrade header field to indicate the new protocol(s) to which the connection is being switched; if multiple protocol layers are being switched, the sender MUST list the protocols in layer-ascending order. | planned | conditional on stallion Upgrade; use `/h/upgrade-target` → verify 101 has Upgrade |
| `rfc9110-7.8-05` | 7.8 | **MUST NOT** | client, server | A server MUST NOT switch to a protocol that was not indicated by the client in the corresponding request's Upgrade header field. | planned | conditional on stallion Upgrade |
| `rfc9110-7.8-06` | 7.8 | **MAY** | client, server | A server MAY choose to ignore the order of preference indicated by the client and select the new protocol(s) based on other factors. | out-of-scope | permission |
| `rfc9110-7.8-07` | 7.8 | **MUST** | server | A server that sends a 426 (Upgrade Required) response MUST send an Upgrade header field to indicate the acceptable protocols, in order of descending preference. | planned | use `/h/status/426` → verify Upgrade header present |
| `rfc9110-7.8-08` | 7.8 | **MAY** | server | A server MAY send an Upgrade header field in any other response to advertise that it implements support for upgrading to the listed protocols. | out-of-scope | permission |
| `rfc9110-7.8-09` | 7.8 | **MUST NOT** | server | A server MUST NOT switch protocols unless the received message semantics can be honored by the new protocol; an OPTIONS request can be honored by any protocol. | planned | conditional on stallion Upgrade |
| `rfc9110-7.8-10` | 7.8 | **MUST** | intermediary, sender | A sender of Upgrade MUST also send an "Upgrade" connection option in the Connection header field to inform intermediaries not to forward this field. | planned | property on server output: any Upgrade-bearing response also lists `Upgrade` in Connection |
| `rfc9110-7.8-11` | 7.8 | **MUST** | server | A server that receives an Upgrade header field in an HTTP/1.0 request MUST ignore that Upgrade field. | planned | accept: HTTP/1.0 + Upgrade header → Upgrade ignored (no 101) |
| `rfc9110-7.8-12` | 7.8 | **MUST** | server | If a server receives both an Upgrade and an Expect header field with the "100-continue" expectation, the server MUST send a 100 (Continue) response before sending a 101 (Switching Protocols) response. | planned | conditional on stallion Upgrade + Expect; compound test |

### representation metadata

_8 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-8.3-01` | 8.3 | **SHOULD** | sender | A sender that generates a message containing content SHOULD generate a Content-Type header field in that message unless the intended media type of the enclosed representation is unknown to the sender. | planned | property on server output: responses with body have Content-Type |
| `rfc9110-8.3-02` | 8.3 | **MAY** | recipient | If a Content-Type header field is not present, the recipient MAY either assume a media type of "application/octet-stream" or examine the data to determine its type. | out-of-scope | permission |
| `rfc9110-8.3.3-01` | 8.3.3 | **MUST** | sender | The message body is itself a protocol element; a sender MUST generate only CRLF to represent line breaks between body parts. | planned | property on multipart server output (covered alongside 206 multipart tests) |
| `rfc9110-8.4-01` | 8.4 | **MUST** | sender | If one or more encodings have been applied to a representation, the sender that applied the encodings MUST generate a Content-Encoding header field that lists the content codings in the order in which they were applied. | planned | conditional on stallion content-encoding: property on server output |
| `rfc9110-8.4-02` | 8.4 | **SHOULD NOT** |  | Note that the coding named "identity" is reserved for its special role in Accept-Encoding and thus SHOULD NOT be included. | planned | property on server output: `identity` not in Content-Encoding |
| `rfc9110-8.4-03` | 8.4 | **MAY** | origin server, server | An origin server MAY respond with a status code of 415 (Unsupported Media Type) if a representation in the request message has a content coding that is not acceptable. | out-of-scope | permission (415 for unacceptable encoding) |
| `rfc9110-8.4.1.1-01` | 8.4.1.1 | **SHOULD** | recipient | A recipient SHOULD consider "x-compress" to be equivalent to "compress". | planned | accept: request with `Accept-Encoding: x-compress` → response with compress equivalent |
| `rfc9110-8.4.1.3-01` | 8.4.1.3 | **SHOULD** | recipient | A recipient SHOULD consider "x-gzip" to be equivalent to "gzip". | planned | accept: request with `Accept-Encoding: x-gzip` → response with gzip equivalent (use /h/negotiated/encoded) |

### Content-Length

_8 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-8.6-03` | 8.6 | **MUST NOT** | server | A server MAY send a Content-Length header field in a response to a HEAD request; a server MUST NOT send Content-Length in such a response unless its field value equals the decimal number of octets that would have been sent in the content of a response if the same request had used the GET method. | planned | HEAD /h/static/text CL matches GET would-be CL |
| `rfc9110-8.6-04` | 8.6 | **MUST NOT** | server | A server MAY send a Content-Length header field in a 304 (Not Modified) response to a conditional GET request; a server MUST NOT send Content-Length in such a response unless its field value equals the decimal number of octets that would have been sent in the content of a 200 (OK) response to the same request. | planned | conditional GET → 304 CL matches 200 CL |
| `rfc9110-8.6-05` | 8.6 | **MUST NOT** | server | A server MUST NOT send a Content-Length header field in any response with a status code of 1xx (Informational) or 204 (No Content). | planned | force 204 (use /h/status/204) → verify no CL |
| `rfc9110-8.6-06` | 8.6 | **MUST NOT** | server | A server MUST NOT send a Content-Length header field in any 2xx (Successful) response to a CONNECT request. | out-of-scope | CONNECT not supported by stallion |
| `rfc9110-8.6-07` | 8.6 | **SHOULD** | origin server, server | Aside from the cases defined above, in the absence of Transfer-Encoding, an origin server SHOULD send a Content-Length header field when the content size is known prior to sending the complete header section. | planned | property: GET 200 to static endpoints has CL |
| `rfc9110-8.6-08` | 8.6 | **MUST** | recipient | A recipient MUST anticipate potentially large decimal numerals and prevent parsing errors due to integer conversion overflows or precision loss due to integer conversion. | planned | send large CL value → graceful handling (no overflow crash) |
| `rfc9110-8.6-09` | 8.6 | **MUST NOT** | sender | A sender MUST NOT forward a message with a Content-Length header field value that is known to be incorrect. | planned | property on server output: response body byte count matches CL exactly |
| `rfc9110-8.6-10` | 8.6 | **MUST NOT** | recipient, sender | A sender MUST NOT forward a message with a Content-Length header field value that does not match the ABNF above, with one exception: a recipient of a Content-Length header field value consisting of the same decimal value repeated as a comma-separated list MAY either reject the message as invalid or replace that invalid field value with a single instance of the decimal value. | planned | duplicate of rfc9112-6.3-04 |

### Content-Location

_3 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-8.7-01` | 8.7 | **MUST** | origin server, server | An origin server that receives a Content-Location field in a request message MUST treat the information as transitory request context rather than as metadata to be saved verbatim as part of the representation. | waived | internal handling; not externally observable |
| `rfc9110-8.7-02` | 8.7 | **MAY** | origin server, server | An origin server MAY use that context to guide in processing the request or to save it for other uses. | out-of-scope | permission |
| `rfc9110-8.7-03` | 8.7 | **MUST NOT** | origin server, server | However, an origin server MUST NOT use such context information to alter the request semantics. | waived | semantic check; hard to verify externally |

### validators (ETag / Last-Modified)

_9 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-8.8.1-01` | 8.8.1 | **SHOULD** | origin server, server | An origin server SHOULD change a weak entity tag whenever it considers prior representations to be unacceptable as a substitute for the current representation. | planned | PUT to /h/mutable; verify weak ETag changes after representation change |
| `rfc9110-8.8.2.1-01` | 8.8.2.1 | **SHOULD** | origin server, server | An origin server SHOULD send Last-Modified for any selected representation for which a last modification date can be reasonably and consistently determined, since its use in conditional requests and evaluating cache freshness can substantially reduce unnecessary transfers and significantly improve service availability and scalability. | planned | verify Last-Modified on /h/static/text |
| `rfc9110-8.8.2.1-02` | 8.8.2.1 | **SHOULD** | origin server, server | An origin server SHOULD obtain the Last-Modified value of the representation as close as possible to the time that it generates the Date field value for its response. | planned | verify Last-Modified close to Date in response |
| `rfc9110-8.8.2.1-03` | 8.8.2.1 | **MUST NOT** | origin server, server | An origin server with a clock MUST NOT generate a Last-Modified date that is later than the server's time of message origination. | planned | verify Last-Modified ≤ Date in response |
| `rfc9110-8.8.2.1-04` | 8.8.2.1 | **MUST** | origin server, server | If the last modification time is derived from implementation-specific metadata that evaluates to some time in the future, according to the origin server's clock, then the origin server MUST replace that value with the message origination date. | waived | requires server-side mock with future timestamp; can't force externally |
| `rfc9110-8.8.2.1-05` | 8.8.2.1 | **MUST NOT** | origin server, server | An origin server without a clock MUST NOT generate a Last-Modified date for a response unless that date value was assigned to the resource by some other system (presumably one with a clock). | out-of-scope | profile: assume stallion has a clock |
| `rfc9110-8.8.3-01` | 8.8.3 | **MUST** | origin server, server | If an origin server provides an entity tag for a representation and the generation of that entity tag does not satisfy all of the characteristics of a strong validator, then the origin server MUST mark the entity tag as weak by prefixing its opaque value with "W/". | planned | property on server output: weak ETags prefixed with `W/` |
| `rfc9110-8.8.3-02` | 8.8.3 | **MAY** | sender | A sender MAY send the ETag field in a trailer section. | out-of-scope | permission |
| `rfc9110-8.8.3.1-01` | 8.8.3.1 | **SHOULD** | origin server, server | An origin server SHOULD send an ETag for any selected representation for which detection of changes can be reasonably and consistently determined. | planned | verify ETag present on /h/static/text |

### methods

_4 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-9.1-01` | 9.1 | **MUST** | server | All general-purpose servers MUST support the methods GET and HEAD. | planned | accept: GET and HEAD on /h/static/text |
| `rfc9110-9.1-02` | 9.1 | **MAY** |  | All other methods are OPTIONAL. | out-of-scope | permission |
| `rfc9110-9.1-03` | 9.1 | **SHOULD** | origin server, server | An origin server that receives a request method that is unrecognized or not implemented SHOULD respond with the 501 (Not Implemented) status code. | planned | duplicate of rfc9112-3-02 |
| `rfc9110-9.1-04` | 9.1 | **SHOULD** | origin server, server | An origin server that receives a request method that is recognized and implemented, but not allowed for the target resource, SHOULD respond with the 405 (Method Not Allowed) status code. | planned | POST /h/get-only → 405 |

### method properties (safe / idempotent)

_2 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-9.2.1-02` | 9.2.1 | **MUST** |  | If the purpose of such a resource is to perform an unsafe action, then the resource owner MUST disable or disallow that action when it is accessed using a safe request method. | waived | semantic; resource-owner discipline, not externally observable |
| `rfc9110-9.2.2-02` | 9.2.2 | **MUST NOT** | proxy | A proxy MUST NOT automatically retry non-idempotent requests. | out-of-scope | proxy-only; stallion is origin |

### method: GET

_2 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-9.3.1-01` | 9.3.1 | **SHOULD NOT** | client, origin server, server | A client SHOULD NOT generate content in a GET request unless it is made directly to an origin server that has previously indicated, in or out of band, that such a request has a purpose and will be adequately supported. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9110-9.3.1-02` | 9.3.1 | **SHOULD NOT** | origin server, server | An origin server SHOULD NOT rely on private agreements to receive content. | waived | deployment policy; not testable externally |

### method: HEAD

_5 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-9.3.2-01` | 9.3.2 | **MUST NOT** | server | The HEAD method is identical to GET except that the server MUST NOT send content in the response. | planned | HEAD /h/static/text → zero body bytes |
| `rfc9110-9.3.2-02` | 9.3.2 | **SHOULD** | server | The server SHOULD send the same header fields in response to a HEAD request as it would have sent if the request method had been GET. | planned | HEAD vs GET to /h/static/text → headers match (modulo 9.3.2-03) |
| `rfc9110-9.3.2-03` | 9.3.2 | **MAY** | server | However, a server MAY omit header fields for which a value is determined only while generating the content. | out-of-scope | permission |
| `rfc9110-9.3.2-04` | 9.3.2 | **SHOULD NOT** | client, origin server, server | A client SHOULD NOT generate content in a HEAD request unless it is made directly to an origin server that has previously indicated, in or out of band, that such a request has a purpose and will be adequately supported. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9110-9.3.2-05` | 9.3.2 | **SHOULD NOT** | origin server, server | An origin server SHOULD NOT rely on private agreements to receive content. | waived | deployment policy; not testable externally |

### method: POST

_2 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-9.3.3-01` | 9.3.3 | **SHOULD** | origin server, server | If one or more resources has been created on the origin server as a result of successfully processing a POST request, the origin server SHOULD send a 201 (Created) response containing a Location header field that provides an identifier for the primary resource created and a representation that describes the status of the request while referring to the new resource(s). | waived | requires a POST-creates-resource endpoint; not in harness for first pass |
| `rfc9110-9.3.3-02` | 9.3.3 | **MAY** | origin server, server, user agent | If the result of processing a POST would be equivalent to a representation of an existing resource, an origin server MAY redirect the user agent to that resource by sending a 303 (See Other) response with the existing resource's identifier in the Location field. | out-of-scope | permission |

### method: PUT

_7 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-9.3.4-01` | 9.3.4 | **MUST** | origin server, server, user agent | If the target resource does not have a current representation and the PUT successfully creates one, then the origin server MUST inform the user agent by sending a 201 (Created) response. | planned | PUT to new key on /h/mutable → 201 + Location |
| `rfc9110-9.3.4-02` | 9.3.4 | **MUST** | origin server, server | If the target resource does have a current representation and that representation is successfully modified in accordance with the state of the enclosed representation, then the origin server MUST send either a 200 (OK) or a 204 (No Content) response to indicate successful completion of the request. | planned | PUT to existing key on /h/mutable → 200 or 204 |
| `rfc9110-9.3.4-03` | 9.3.4 | **SHOULD** | origin server, server | An origin server SHOULD verify that the PUT representation is consistent with its configured constraints for the target resource. | waived | semantic constraint verification; not testable as conformance |
| `rfc9110-9.3.4-04` | 9.3.4 | **SHOULD** | origin server, server | When a PUT representation is inconsistent with the target resource, the origin server SHOULD either make them consistent, by transforming the representation or changing the resource configuration, or respond with an appropriate error message containing sufficient information to explain why the representation is unsuitable. | waived | semantic; not testable as conformance |
| `rfc9110-9.3.4-05` | 9.3.4 | **SHOULD** | origin server, server | An origin server SHOULD ignore unrecognized header and trailer fields received in a PUT request (i.e., not save them as part of the resource state). | planned | PUT with X-Random header → resource state unaffected |
| `rfc9110-9.3.4-06` | 9.3.4 | **MUST NOT** | origin server, server | An origin server MUST NOT send a validator field, such as an ETag or Last-Modified field, in a successful response to PUT unless the request's representation data was saved without any transformation applied to the content and the validator field value reflects the new representation. | planned | property: validator in PUT response matches subsequent GET |
| `rfc9110-9.3.4-08` | 9.3.4 | **MUST** | origin server, server, user agent | If the origin server will not make the requested PUT state change to the target resource and instead wishes to have it applied to a different resource, then the origin server MUST send an appropriate 3xx (Redirection) response; the user agent MAY then make its own decision regarding whether or not to redirect the request. | waived | requires a PUT-redirect endpoint; not in harness for first pass |

### method: DELETE

_3 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-9.3.5-01` | 9.3.5 | **SHOULD** | origin server, server | If a DELETE method is successfully applied, the origin server SHOULD send a 202 (Accepted) status code if the action will likely succeed but has not yet been enacted, a 204 (No Content) status code if the action has been enacted and no further information is to be supplied, or a 200 (OK) status code if the action has been enacted and the response message includes a representation describing the status. | planned | DELETE on /h/mutable → 200/202/204 |
| `rfc9110-9.3.5-02` | 9.3.5 | **SHOULD NOT** | client, origin server, server | A client SHOULD NOT generate content in a DELETE request unless it is made directly to an origin server that has previously indicated, in or out of band, that such a request has a purpose and will be adequately supported. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9110-9.3.5-03` | 9.3.5 | **SHOULD NOT** | origin server, server | An origin server SHOULD NOT rely on private agreements to receive content. | waived | deployment policy; not testable externally |

### method: CONNECT

_5 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-9.3.6-02` | 9.3.6 | **MUST** | server | A server MUST reject a CONNECT request that targets an empty or invalid port number, typically by responding with a 400 (Bad Request) status code. | out-of-scope | CONNECT not supported by stallion |
| `rfc9110-9.3.6-03` | 9.3.6 | **MAY** | origin server, server | An origin server MAY accept a CONNECT request, but most origin servers do not implement CONNECT. | out-of-scope | CONNECT not supported by stallion |
| `rfc9110-9.3.6-04` | 9.3.6 | **MUST** | intermediary | A tunnel is closed when a tunnel intermediary detects that either side has closed its connection: the intermediary MUST attempt to send any outstanding data that came from the closed side to the other side, close both connections, and then discard any remaining data left undelivered. | out-of-scope | intermediary-only; CONNECT not supported |
| `rfc9110-9.3.6-05` | 9.3.6 | **SHOULD** | proxy | Proxies that support CONNECT SHOULD restrict its use to a limited set of known ports or a configurable list of safe request targets. | out-of-scope | proxy-only; CONNECT not supported |
| `rfc9110-9.3.6-06` | 9.3.6 | **MUST NOT** | server | A server MUST NOT send any Transfer-Encoding or Content-Length header fields in a 2xx (Successful) response to CONNECT. | out-of-scope | CONNECT not supported by stallion |

### method: OPTIONS

_3 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-9.3.7-01` | 9.3.7 | **SHOULD** | server | A server generating a successful response to OPTIONS SHOULD send any header that might indicate optional features implemented by the server and applicable to the target resource, including potential extensions not defined by this specification. | planned | OPTIONS /h/static/text → response has Allow (and other indicative headers) |
| `rfc9110-9.3.7-02` | 9.3.7 | **MAY** | client, recipient | A client MAY send a Max-Forwards header field in an OPTIONS request to target a specific recipient in the request chain. | out-of-scope | client-only |
| `rfc9110-9.3.7-03` | 9.3.7 | **MUST NOT** | proxy | A proxy MUST NOT generate a Max-Forwards header field while forwarding a request unless that request was received with a Max-Forwards field. | out-of-scope | proxy-only; stallion is origin |

### method: TRACE

_2 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-9.3.8-01` | 9.3.8 | **SHOULD** | client, recipient | The final recipient of the request SHOULD reflect the message received, excluding some fields described below, back to the client as the content of a 200 (OK) response. | planned | deferred to later pass: TRACE /h/trace-target → 200 with message/http body reflecting request |
| `rfc9110-9.3.8-03` | 9.3.8 | **SHOULD** | recipient | The final recipient of the request SHOULD exclude any request fields that are likely to contain sensitive data when that recipient generates the response content. | planned | deferred to later pass: TRACE with Authorization/Cookie → response body excludes those fields |

### request context fields

_6 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-10.1.2-02` | 10.1.2 | **SHOULD** | server, user agent | A robotic user agent SHOULD send a valid From header field so that the person responsible for running the robot can be contacted if problems occur on servers. | out-of-scope | user-agent only (role classifier misfire); propose appendix move |
| `rfc9110-10.1.2-03` | 10.1.2 | **SHOULD NOT** | server | A server SHOULD NOT use the From header field for access control or authentication, since its value is expected to be visible to anyone receiving or observing the request and is often recorded within logfiles and error reports without any expectation of privacy. | waived | server policy on auth; not testable externally |
| `rfc9110-10.1.3-06` | 10.1.3 | **SHOULD NOT** | intermediary | An intermediary SHOULD NOT modify or delete the Referer header field when the field value shares the same scheme and host as the target URI. | out-of-scope | intermediary-only; stallion is origin |
| `rfc9110-10.1.4-01` | 10.1.4 | **MUST** | intermediary, sender | A sender of TE MUST also send a "TE" connection option within the Connection header field to inform intermediaries not to forward this field. | planned | duplicate of rfc9112-7.4-03 |
| `rfc9110-10.1.5-02` | 10.1.5 | **MUST NOT** | sender | A sender SHOULD limit generated product identifiers to what is necessary to identify the product; a sender MUST NOT generate advertising or other nonessential information within the product identifier. | planned | property on Server header: no advertising in product identifier |
| `rfc9110-10.1.5-03` | 10.1.5 | **SHOULD NOT** | sender | A sender SHOULD NOT generate information in product-version that is not a version identifier. | planned | property on Server header: product-version is a version identifier |

### Expect / 100-continue

_10 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-10.1.1-01` | 10.1.1 | **MAY** | server | A server that receives an Expect field value containing a member other than 100-continue MAY respond with a 417 (Expectation Failed) status code to indicate that the unexpected expectation cannot be met. | planned | profile: send `Expect: foo` → 417 (conditional on stallion Expect handling) |
| `rfc9110-10.1.1-05` | 10.1.1 | **SHOULD NOT** | client, intermediary | Furthermore, since 100 (Continue) responses cannot be sent through an HTTP/1.0 intermediary, such a client SHOULD NOT wait for an indefinite period before sending the content. | out-of-scope | client-only (role classifier misfire); propose appendix move |
| `rfc9110-10.1.1-07` | 10.1.1 | **MUST** | server | A server that receives a 100-continue expectation in an HTTP/1.0 request MUST ignore that expectation. | planned | send HTTP/1.0 + `Expect: 100-continue` → no 1xx, only final response |
| `rfc9110-10.1.1-08` | 10.1.1 | **MAY** | server | A server MAY omit sending a 100 (Continue) response if it has already received some or all of the content for the corresponding request, or if the framing indicates that there is no content. | out-of-scope | permission |
| `rfc9110-10.1.1-09` | 10.1.1 | **MUST** | server | A server that sends a 100 (Continue) response MUST ultimately send a final status code, once it receives and processes the request content, unless the connection is closed prematurely. | planned | conditional pending stallion Expect handling: server sends final status after 100 |
| `rfc9110-10.1.1-10` | 10.1.1 | **SHOULD** | server | A server that responds with a final status code before reading the entire request content SHOULD indicate whether it intends to close the connection or continue reading the request content. | planned | conditional pending stallion Expect handling: indicate close/continue after early final |
| `rfc9110-10.1.1-11` | 10.1.1 | **MUST** | client, origin server, server | Upon receiving an HTTP/1.1 (or later) request that has a method, target URI, and complete header section that contains a 100-continue expectation and an indication that request content will follow, an origin server MUST send either an immediate response with a final status code, if that status can be determined by examining just the method, target URI, and header fields, or an immediate 100 (Continue) response to encourage the client to send the request content. | planned | conditional pending stallion Expect handling: 100 or final sent immediately |
| `rfc9110-10.1.1-12` | 10.1.1 | **MUST NOT** | origin server, server | The origin server MUST NOT wait for the content before sending the 100 (Continue) response. | planned | conditional pending stallion Expect handling: timing test — 100 arrives before body sent |
| `rfc9110-10.1.1-13` | 10.1.1 | **MUST** | origin server, proxy, server | Upon receiving an HTTP/1.1 (or later) request that has a method, target URI, and complete header section that contains a 100-continue expectation and indicates a request content will follow, a proxy MUST either send an immediate response with a final status code, if that status can be determined by examining just the method, target URI, and header fields, or forward the request toward the origin server by sending a corresponding request-line and header section to the next inbound server. | out-of-scope | proxy-only branch; origin half covered by 10.1.1-11 |
| `rfc9110-10.1.1-14` | 10.1.1 | **MAY** | client, proxy, server | If the proxy believes that the next inbound server only supports HTTP/1.0, the proxy MAY generate an immediate 100 (Continue) response to encourage the client to begin sending the content. | out-of-scope | proxy-only |

### response context fields

_4 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-10.2.1-01` | 10.2.1 | **MUST** | origin server, server | An origin server MUST generate an Allow header field in a 405 (Method Not Allowed) response and MAY do so in any other response. | planned | POST /h/get-only → 405 with Allow listing GET, HEAD |
| `rfc9110-10.2.1-02` | 10.2.1 | **MUST NOT** | proxy | A proxy MUST NOT modify the Allow header field. | out-of-scope | proxy-only; stallion is origin |
| `rfc9110-10.2.4-01` | 10.2.4 | **MAY** | origin server, server | An origin server MAY generate a Server header field in its responses. | out-of-scope | permission |
| `rfc9110-10.2.4-02` | 10.2.4 | **SHOULD NOT** | origin server, server | An origin server SHOULD NOT generate a Server header field containing needlessly fine-grained detail and SHOULD limit the addition of subproducts by third parties. | waived | subjective ("needlessly fine-grained") |

### authentication

_8 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-11.2-01` | 11.2 | **MUST** |  | Authentication parameters are name/value pairs, where the name token is matched case-insensitively and each parameter name MUST only occur once per challenge. | planned | property on /h/protected WWW-Authenticate: each parameter name unique |
| `rfc9110-11.5-01` | 11.5 | **MUST** | sender | For historical reasons, a sender MUST only generate the quoted-string syntax. | planned | property on /h/protected WWW-Authenticate: parameter values use quoted-string |
| `rfc9110-11.6.1-01` | 11.6.1 | **MUST** | server | A server generating a 401 (Unauthorized) response MUST send a WWW-Authenticate header field containing at least one challenge. | planned | GET /h/protected without creds → 401 with WWW-Authenticate |
| `rfc9110-11.6.1-02` | 11.6.1 | **MAY** | server | A server MAY generate a WWW-Authenticate header field in other response messages to indicate that supplying credentials (or different credentials) might affect the response. | out-of-scope | permission |
| `rfc9110-11.6.1-03` | 11.6.1 | **MUST NOT** | proxy | A proxy forwarding a response MUST NOT modify any WWW-Authenticate header fields in that response. | out-of-scope | proxy-only |
| `rfc9110-11.6.2-01` | 11.6.2 | **MUST NOT** | proxy | A proxy forwarding a request MUST NOT modify any Authorization header fields in that request. | out-of-scope | proxy-only |
| `rfc9110-11.7.1-01` | 11.7.1 | **MUST** | proxy | A proxy MUST send at least one Proxy-Authenticate header field in each 407 (Proxy Authentication Required) response that it generates. | out-of-scope | proxy-only |
| `rfc9110-11.7.2-01` | 11.7.2 | **MAY** | client, proxy | A proxy MAY relay the credentials from the client request to the next proxy if that is the mechanism by which the proxies cooperatively authenticate a given request. | out-of-scope | proxy-only |

### content negotiation

_7 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-12.4.2-01` | 12.4.2 | **MUST NOT** | sender | A sender of qvalue MUST NOT generate more than three digits after the decimal point. | planned | property on server output: any emitted qvalue has ≤ 3 decimal digits |
| `rfc9110-12.5.1-01` | 12.5.1 | **SHOULD** | sender | Senders using weights SHOULD send "q" last (after all media-range parameters). | planned | property on server output: q parameter is last (rare for servers) |
| `rfc9110-12.5.1-02` | 12.5.1 | **SHOULD** | recipient | Recipients SHOULD process any parameter named "q" as weight, regardless of parameter ordering. | planned | send `Accept: text/html;foo=bar;q=0.9` to /h/negotiated/greeting → q honored |
| `rfc9110-12.5.3-01` | 12.5.3 | **SHOULD** | origin server, server | If a non-empty Accept-Encoding header field is present in a request and none of the available representations for the response have a content coding that is listed as acceptable, the origin server SHOULD send a response without any content coding unless the identity coding is indicated as unacceptable. | planned | /h/negotiated/encoded with unacceptable Accept-Encoding → identity response |
| `rfc9110-12.5.3-02` | 12.5.3 | **MUST NOT** | server | Servers that fail a request with a 415 status for reasons unrelated to content codings MUST NOT include the Accept-Encoding header field. | planned | property: 415 unrelated to coding has no Accept-Encoding |
| `rfc9110-12.5.5-01` | 12.5.5 | **MUST NOT** | proxy | A proxy MUST NOT generate "*" in a Vary field value. | out-of-scope | proxy-only |
| `rfc9110-12.5.5-02` | 12.5.5 | **SHOULD** | origin server, server | An origin server SHOULD generate a Vary header field on a cacheable response when it wishes that response to be selectively reused for subsequent requests. | planned | property: /h/negotiated/greeting response has Vary: Accept |

### conditional requests

_29 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-13.1.1-01` | 13.1.1 | **MUST** | client, origin server, server | An origin server MUST use the strong comparison function when comparing entity tags for If-Match, since the client intends this precondition to prevent the method from being applied if there have been any changes to the representation data. | planned | If-Match with weak ETag `W/"weak-v1"` on /h/static/weak → 412 (weak doesn't satisfy strong comparison) |
| `rfc9110-13.1.1-02` | 13.1.1 | **MUST** | origin server, server | When an origin server receives a request that selects a representation and that request includes an If-Match header field, the origin server MUST evaluate the If-Match condition prior to performing the method. | planned | If-Match with mismatched ETag on PUT /h/mutable → 412 (no mutation happened) |
| `rfc9110-13.1.1-03` | 13.1.1 | **MUST NOT** | origin server, server | An origin server that evaluates an If-Match condition MUST NOT perform the requested method if the condition evaluates to false. | planned | covered by 13.1.1-02; verify state unchanged |
| `rfc9110-13.1.1-04` | 13.1.1 | **MAY** | origin server, server | Instead, the origin server MAY indicate that the conditional request failed by responding with a 412 (Precondition Failed) status code. | planned | If-Match false → 412 |
| `rfc9110-13.1.1-05` | 13.1.1 | **MAY** | origin server, server | Alternatively, if the request is a state-changing operation that appears to have already been applied to the selected representation, the origin server MAY respond with a 2xx (Successful) status code. | planned | replay same PUT with If-Match matching → 2xx (already-applied) |
| `rfc9110-13.1.1-07` | 13.1.1 | **MAY** | intermediary, origin server, server | A cache or intermediary MAY ignore If-Match because its interoperability features are only necessary for an origin server. | out-of-scope | permission for cache/intermediary |
| `rfc9110-13.1.2-01` | 13.1.2 | **MUST** | recipient | A recipient MUST use the weak comparison function when comparing entity tags for If-None-Match, since weak entity tags can be used for cache validation even if there have been changes to the representation data. | planned | If-None-Match weak match on /h/static/weak → 304 |
| `rfc9110-13.1.2-02` | 13.1.2 | **MUST** | origin server, server | When an origin server receives a request that selects a representation and that request includes an If-None-Match header field, the origin server MUST evaluate the If-None-Match condition prior to performing the method. | planned | covered by 13.1.2-04 test material |
| `rfc9110-13.1.2-04` | 13.1.2 | **MUST NOT** | origin server, server | An origin server that evaluates an If-None-Match condition MUST NOT perform the requested method if the condition evaluates to false; instead, the origin server MUST respond with either the 304 (Not Modified) status code if the request method is GET or HEAD or the 412 (Precondition Failed) status code for all other request methods. | planned | GET → 304; PUT → 412 when If-None-Match condition false |
| `rfc9110-13.1.3-01` | 13.1.3 | **MUST** | recipient | A recipient MUST ignore If-Modified-Since if the request contains an If-None-Match header field. | planned | send both → If-None-Match wins; If-Modified-Since ignored |
| `rfc9110-13.1.3-02` | 13.1.3 | **MUST** | recipient | A recipient MUST ignore the If-Modified-Since header field if the received field value is not a valid HTTP-date, the field value has more than one member, or if the request method is neither GET nor HEAD. | planned | three sub-tests: bad date, multi-value, non-GET/HEAD |
| `rfc9110-13.1.3-03` | 13.1.3 | **MUST** | recipient | A recipient MUST ignore the If-Modified-Since header field if the resource does not have a modification date available. | planned | If-Modified-Since on /h/static/no-validators → ignored (200 returned) |
| `rfc9110-13.1.3-04` | 13.1.3 | **MUST** | origin server, recipient, server | A recipient MUST interpret an If-Modified-Since field value's timestamp in terms of the origin server's clock. | waived | semantic; origin clock interpretation not directly observable |
| `rfc9110-13.1.3-05` | 13.1.3 | **SHOULD** | origin server, server | When an origin server receives a request that selects a representation and that request includes an If-Modified-Since header field without an If-None-Match header field, the origin server SHOULD evaluate the If-Modified-Since condition prior to performing the method. | planned | If-Modified-Since condition affects response |
| `rfc9110-13.1.3-06` | 13.1.3 | **SHOULD NOT** | origin server, server | An origin server that evaluates an If-Modified-Since condition SHOULD NOT perform the requested method if the condition evaluates to false; instead, the origin server SHOULD generate a 304 (Not Modified) response, including only those metadata that are useful for identifying or updating a previously cached response. | planned | If-Modified-Since false → 304 with minimal metadata |
| `rfc9110-13.1.4-01` | 13.1.4 | **MUST** | recipient | A recipient MUST ignore If-Unmodified-Since if the request contains an If-Match header field. | planned | both present → If-Match wins |
| `rfc9110-13.1.4-02` | 13.1.4 | **MUST** | recipient | A recipient MUST ignore the If-Unmodified-Since header field if the received field value is not a valid HTTP-date. | planned | bad date → ignored |
| `rfc9110-13.1.4-03` | 13.1.4 | **MUST** | recipient | A recipient MUST ignore the If-Unmodified-Since header field if the resource does not have a modification date available. | planned | If-Unmodified-Since on /h/static/no-validators → ignored |
| `rfc9110-13.1.4-04` | 13.1.4 | **MUST** | origin server, recipient, server | A recipient MUST interpret an If-Unmodified-Since field value's timestamp in terms of the origin server's clock. | waived | semantic; not directly observable |
| `rfc9110-13.1.4-05` | 13.1.4 | **MUST** | origin server, server | When an origin server receives a request that selects a representation and that request includes an If-Unmodified-Since header field without an If-Match header field, the origin server MUST evaluate the If-Unmodified-Since condition prior to performing the method. | planned | If-Unmodified-Since affects response |
| `rfc9110-13.1.4-06` | 13.1.4 | **MUST NOT** | origin server, server | An origin server that evaluates an If-Unmodified-Since condition MUST NOT perform the requested method if the condition evaluates to false. | planned | PUT with old If-Unmodified-Since on modified resource → no mutation |
| `rfc9110-13.1.4-07` | 13.1.4 | **MAY** | origin server, server | Instead, the origin server MAY indicate that the conditional request failed by responding with a 412 (Precondition Failed) status code. | planned | 412 alternative |
| `rfc9110-13.1.4-08` | 13.1.4 | **MAY** | origin server, server | Alternatively, if the request is a state-changing operation that appears to have already been applied to the selected representation, the origin server MAY respond with a 2xx (Successful) status code. | planned | 2xx alternative |
| `rfc9110-13.1.4-10` | 13.1.4 | **MAY** | intermediary, origin server, server | A cache or intermediary MAY ignore If-Unmodified-Since because its interoperability features are only necessary for an origin server. | out-of-scope | permission for cache/intermediary |
| `rfc9110-13.1.5-02` | 13.1.5 | **MUST** | server | A server MUST ignore an If-Range header field received in a request that does not contain a Range header field. | planned | If-Range without Range on /h/static/ranged → ignored (200) |
| `rfc9110-13.1.5-03` | 13.1.5 | **MUST** | origin server, server | An origin server MUST ignore an If-Range header field received in a request for a target resource that does not support Range requests. | planned | If-Range on /h/static/no-range → ignored |
| `rfc9110-13.1.5-06` | 13.1.5 | **MUST** | server | A server that receives an If-Range header field on a Range request MUST evaluate the condition prior to performing the method. | planned | If-Range + Range on /h/static/ranged → condition evaluated |
| `rfc9110-13.1.5-07` | 13.1.5 | **MUST** | recipient | A recipient of an If-Range header field MUST ignore the Range header field if the If-Range condition evaluates to false. | planned | If-Range false → full 200, not 206 |
| `rfc9110-13.1.5-08` | 13.1.5 | **SHOULD** | recipient | Otherwise, the recipient SHOULD process the Range header field as requested. | planned | If-Range true → 206 |

### conditional: evaluation

_5 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-13.2.1-01` | 13.2.1 | **MUST** | origin server, recipient, server | Except when excluded below, a recipient cache or origin server MUST evaluate received request preconditions after it has successfully performed its normal request checks and just before it would process the request content or perform the action associated with the request method. | planned | send invalid request + If-Match → 4xx for invalidity precedes If-Match evaluation |
| `rfc9110-13.2.1-02` | 13.2.1 | **MUST** | server | A server MUST ignore all received preconditions if its response to the same request without those conditions, prior to processing the request content, would have been a status code other than a 2xx (Successful) or 412 (Precondition Failed). | planned | preconditions on a 404 target → 404, not 412 |
| `rfc9110-13.2.1-03` | 13.2.1 | **MUST NOT** | origin server, server | A server that is not the origin server for the target resource and cannot act as a cache for requests on the target resource MUST NOT evaluate the conditional request header fields defined by this specification, and it MUST forward them if the request is forwarded. | out-of-scope | non-origin server; stallion is origin |
| `rfc9110-13.2.1-04` | 13.2.1 | **MUST** | server | A server MUST ignore the conditional request header fields defined by this specification when received with a request method that does not involve the selection or modification of a selected representation, such as CONNECT, OPTIONS, or TRACE. | planned | OPTIONS /h/static/text + If-Match → If-Match ignored |
| `rfc9110-13.2.2-01` | 13.2.2 | **MUST** | origin server, recipient, server | A recipient cache or origin server MUST evaluate the request preconditions defined by this specification in the following order: If-Match, If-Unmodified-Since, If-None-Match, If-Modified-Since, and finally If-Range. | planned | compound: If-Match satisfying + If-Unmodified-Since failing → behavior shows If-Match took precedence |

### range requests

_16 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-14.1.2-01` | 14.1.2 | **MUST** | recipient | Recipients MUST anticipate potentially large decimal numerals and prevent parsing errors due to integer conversion overflows. | planned | Range with very large decimal values on /h/static/ranged → graceful handling |
| `rfc9110-14.2-01` | 14.2 | **MAY** | server | A server MAY ignore the Range header field. | out-of-scope | permission to ignore Range |
| `rfc9110-14.2-02` | 14.2 | **MUST** | server | A server MUST ignore a Range header field received with a request method that is unrecognized or for which range handling is not defined. | planned | POST /h/static/ranged with Range header → Range ignored |
| `rfc9110-14.2-03` | 14.2 | **MUST** | origin server, server | An origin server MUST ignore a Range header field that contains a range unit it does not understand. | planned | `Range: foo=0-100` on /h/static/ranged → Range ignored (200 returned) |
| `rfc9110-14.2-04` | 14.2 | **MAY** | proxy | A proxy MAY discard a Range header field that contains a range unit it does not understand. | out-of-scope | proxy-only |
| `rfc9110-14.2-05` | 14.2 | **MAY** | server | A server that supports range requests MAY ignore or reject a Range header field that contains an invalid ranges-specifier, a ranges-specifier with more than two overlapping ranges, or a set of many small ranges that are not listed in ascending order. | out-of-scope | permission |
| `rfc9110-14.2-07` | 14.2 | **MAY** | server | A server that supports range requests MAY ignore a Range header field when the selected representation has no content. | out-of-scope | permission |
| `rfc9110-14.2-09` | 14.2 | **SHOULD** | server | If all of the preconditions are true, the server supports the Range header field for the target resource, the received Range field-value contains a valid ranges-specifier with a range-unit supported for that target resource, and that ranges-specifier is satisfiable with respect to the selected representation, the server SHOULD send a 206 (Partial Content) response with content containing one or more partial representations. | planned | valid Range on /h/static/ranged → 206 |
| `rfc9110-14.2-10` | 14.2 | **SHOULD** | server | If all of the preconditions are true, the server supports the Range header field, the received Range field-value contains a valid ranges-specifier, and either the range-unit is not supported for that target resource or the ranges-specifier is unsatisfiable with respect to the selected representation, the server SHOULD send a 416 (Range Not Satisfiable) response. | planned | unsatisfiable Range on /h/static/ranged → 416 |
| `rfc9110-14.4-01` | 14.4 | **MUST NOT** | recipient | If a 206 (Partial Content) response contains a Content-Range header field with a range unit that the recipient does not understand, the recipient MUST NOT attempt to recombine it with a stored representation. | out-of-scope | client-only (recipient of 206); propose appendix move |
| `rfc9110-14.4-02` | 14.4 | **SHOULD** | proxy | A proxy that receives such a message SHOULD forward it downstream. | out-of-scope | proxy-only |
| `rfc9110-14.4-03` | 14.4 | **MUST** | server | A server MUST ignore a Content-Range header field received in a request with a method for which Content-Range support is not defined. | planned | GET with Content-Range header → ignored |
| `rfc9110-14.4-04` | 14.4 | **SHOULD** | sender | For byte ranges, a sender SHOULD indicate the complete length of the representation from which the range has been extracted, unless the complete length is unknown or difficult to determine. | planned | property: server's Content-Range in 206 includes complete length (e.g., `bytes 0-99/10240`) |
| `rfc9110-14.4-05` | 14.4 | **MUST NOT** | recipient | The recipient of an invalid Content-Range MUST NOT attempt to recombine the received content with a stored representation. | out-of-scope | client-only (recipient of bad Content-Range); propose appendix move |
| `rfc9110-14.4-06` | 14.4 | **SHOULD** | server | A server generating a 416 (Range Not Satisfiable) response to a byte-range request SHOULD send a Content-Range header field with an unsatisfied-range value. | planned | 416 from /h/static/ranged → Content-Range with `*/10240` |
| `rfc9110-14.5-01` | 14.5 | **SHOULD** | origin server, server | An origin server SHOULD respond with a 400 (Bad Request) status code if it receives Content-Range on a PUT for a target resource that does not support partial PUT requests. | planned | PUT /h/mutable with Content-Range → 400 |

### status codes

_1 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-15-02` | 15 | **SHOULD** | client, server | A client that receives a response with an invalid status code SHOULD process the response as if it had a 5xx (Server Error) status code. | out-of-scope | client-only (role classifier misfire); propose appendix move |

### status: 1xx

_3 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-15.2-01` | 15.2 | **MUST NOT** | client, server | A server MUST NOT send a 1xx response to an HTTP/1.0 client. | planned | send HTTP/1.0 + Expect: 100-continue → no 1xx response (overlaps 10.1.1-07) |
| `rfc9110-15.2-04` | 15.2 | **MUST** | proxy | A proxy MUST forward 1xx responses unless the proxy itself requested the generation of the 1xx response. | out-of-scope | proxy-only |
| `rfc9110-15.2.2-01` | 15.2.2 | **MUST** | server | The server MUST generate an Upgrade header field in the response that indicates which protocol(s) will be in effect after this response. | planned | duplicate of 7.8-04 |

### status: 2xx

_2 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-15.3.1-01` | 15.3.1 | **SHOULD** | origin server, server | In 200 responses to GET or HEAD, an origin server SHOULD send any available validator fields for the selected representation, with both a strong entity tag and a Last-Modified date being preferred. | planned | verify ETag + Last-Modified on /h/static/text |
| `rfc9110-15.3.6-01` | 15.3.6 | **MUST NOT** | server | Since the 205 status code implies that no additional content will be provided, a server MUST NOT generate content in a 205 response. | waived | requires /h/status/205; not in harness for first pass |

### status: 206 partial content

_12 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-15.3.7-02` | 15.3.7 | **MUST** | server | A server that generates a 206 response MUST generate the following header fields, in addition to those required in the subsections below, if the field would have been sent in a 200 (OK) response to the same request: Date, Cache-Control, ETag, Expires, Content-Location, and Vary. | planned | property: 206 from /h/static/ranged includes Date, ETag (others if /h/static/ranged would send them in 200) |
| `rfc9110-15.3.7-03` | 15.3.7 | **SHOULD NOT** | client, sender | A sender that generates a 206 response to a request with an If-Range header field SHOULD NOT generate other representation header fields beyond those required because the client already has a prior response containing those header fields. | planned | 206 with If-Range → SHOULD NOT include other representation headers |
| `rfc9110-15.3.7-04` | 15.3.7 | **MUST** | sender | Otherwise, a sender MUST generate all of the representation header fields that would have been sent in a 200 (OK) response to the same request. | planned | 206 without If-Range → includes all representation headers |
| `rfc9110-15.3.7.1-01` | 15.3.7.1 | **MUST** | server | If a single part is being transferred, the server generating the 206 response MUST generate a Content-Range header field, describing what range of the selected representation is enclosed. | planned | single-range Range request → 206 with Content-Range |
| `rfc9110-15.3.7.2-01` | 15.3.7.2 | **MUST** | server | If multiple parts are being transferred, the server generating the 206 response MUST generate "multipart/byteranges" content and a Content-Type header field containing the "multipart/byteranges" media type and its required boundary parameter. | planned | multi-range Range request → multipart/byteranges with boundary |
| `rfc9110-15.3.7.2-02` | 15.3.7.2 | **MUST NOT** | server | To avoid confusion with single-part responses, a server MUST NOT generate a Content-Range header field in the HTTP header section of a multiple part response. | planned | multipart 206 → no top-level Content-Range |
| `rfc9110-15.3.7.2-03` | 15.3.7.2 | **MUST** | server | Within the header area of each body part in the multipart content, the server MUST generate a Content-Range header field corresponding to the range being enclosed in that body part. | planned | each multipart body part has Content-Range |
| `rfc9110-15.3.7.2-04` | 15.3.7.2 | **SHOULD** | server | If the selected representation would have had a Content-Type header field in a 200 (OK) response, the server SHOULD generate that same Content-Type header field in the header area of each body part. | planned | each multipart body part has Content-Type |
| `rfc9110-15.3.7.2-05` | 15.3.7.2 | **MAY** | server | A server MAY coalesce any of the ranges that overlap, or that are separated by a gap that is smaller than the overhead of sending multiple parts. | out-of-scope | permission to coalesce |
| `rfc9110-15.3.7.2-06` | 15.3.7.2 | **MUST NOT** | server | A server MUST NOT generate a multipart response to a request for a single range. | planned | single-range request → single-part 206, not multipart |
| `rfc9110-15.3.7.2-07` | 15.3.7.2 | **MAY** | server | However, a server MAY generate a "multipart/byteranges" response with only a single body part if multiple ranges were requested and only one range was found to be satisfiable or only one range remained after coalescing. | out-of-scope | permission |
| `rfc9110-15.3.7.2-09` | 15.3.7.2 | **SHOULD** | server | A server that generates a multipart response SHOULD send the parts in the same order that the corresponding range-spec appeared in the received Range header field, excluding those ranges that were deemed unsatisfiable or that were coalesced into other ranges. | planned | multi-range request → parts in same order as Range |

### status: 3xx redirects

_9 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-15.4.1-01` | 15.4.1 | **SHOULD** | server | If the server has a preferred choice, the server SHOULD generate a Location header field containing a preferred choice's URI reference. | waived | requires /h/status/300; not in harness for first pass |
| `rfc9110-15.4.1-02` | 15.4.1 | **SHOULD** | server, user agent | For request methods other than HEAD, the server SHOULD generate content in the 300 response containing a list of representation metadata and URI reference(s) from which the user or user agent can choose the one most preferred. | waived | requires /h/status/300; not in harness for first pass |
| `rfc9110-15.4.2-01` | 15.4.2 | **SHOULD** | server | The server SHOULD generate a Location header field in the response containing a preferred URI reference for the new permanent URI. | planned | GET /h/status/301 → Location present |
| `rfc9110-15.4.3-01` | 15.4.3 | **SHOULD** | server | The server SHOULD generate a Location header field in the response containing a URI reference for the different URI. | planned | GET /h/status/302 → Location present |
| `rfc9110-15.4.5-01` | 15.4.5 | **MUST** | server | The server generating a 304 response MUST generate any of the following header fields that would have been sent in a 200 (OK) response to the same request: Content-Location, Date, ETag, and Vary, and Cache-Control and Expires. | planned | conditional GET on /h/static/text → 304 with required headers |
| `rfc9110-15.4.5-02` | 15.4.5 | **SHOULD NOT** | sender | A sender SHOULD NOT generate representation metadata other than the above listed fields unless said metadata exists for the purpose of guiding cache updates. | planned | property on 304 response: only listed fields (plus cache-update-related) |
| `rfc9110-15.4.5-03` | 15.4.5 | **SHOULD** | client, proxy | If the conditional request originated with an outbound client, then the proxy SHOULD forward the 304 response to that client. | out-of-scope | proxy-only |
| `rfc9110-15.4.8-02` | 15.4.8 | **SHOULD** | server | The server SHOULD generate a Location header field in the response containing a URI reference for the different URI. | planned | GET /h/status/307 → Location present |
| `rfc9110-15.4.9-01` | 15.4.9 | **SHOULD** | server | The server SHOULD generate a Location header field in the response containing a preferred URI reference for the new permanent URI. | planned | GET /h/status/308 → Location present |

### status: 4xx

_11 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-15.5-01` | 15.5 | **SHOULD** | server | Except when responding to a HEAD request, the server SHOULD send a representation containing an explanation of the error situation, and whether it is a temporary or permanent condition. | planned | verify 4xx responses (e.g., /h/status/403, /h/status/404) have non-empty body for GET |
| `rfc9110-15.5.2-01` | 15.5.2 | **MUST** | server | The server generating a 401 response MUST send a WWW-Authenticate header field containing at least one challenge applicable to the target resource. | planned | duplicate of 11.6.1-01 |
| `rfc9110-15.5.4-03` | 15.5.4 | **MAY** | origin server, server | An origin server that wishes to "hide" the current existence of a forbidden target resource MAY instead respond with a status code of 404 (Not Found). | out-of-scope | permission |
| `rfc9110-15.5.6-01` | 15.5.6 | **MUST** | origin server, server | The origin server MUST generate an Allow header field in a 405 response containing a list of the target resource's currently supported methods. | planned | duplicate of 10.2.1-01 |
| `rfc9110-15.5.7-01` | 15.5.7 | **SHOULD** | server, user agent | The server SHOULD generate content containing a list of available representation characteristics and corresponding resource identifiers from which the user or user agent can choose the one most appropriate. | waived | requires /h/status/406; not in harness for first pass |
| `rfc9110-15.5.8-01` | 15.5.8 | **MUST** | proxy | The proxy MUST send a Proxy-Authenticate header field containing a challenge applicable to that proxy for the request. | out-of-scope | proxy-only |
| `rfc9110-15.5.14-01` | 15.5.14 | **MAY** | server | The server MAY terminate the request, if the protocol version in use allows it; otherwise, the server MAY close the connection. | out-of-scope | permission |
| `rfc9110-15.5.14-02` | 15.5.14 | **SHOULD** | client, server | If the condition is temporary, the server SHOULD generate a Retry-After header field to indicate that it is temporary and after what time the client MAY try again. | planned | GET /h/status/503 → Retry-After present |
| `rfc9110-15.5.17-01` | 15.5.17 | **SHOULD** | server | A server that generates a 416 response to a byte-range request SHOULD generate a Content-Range header field specifying the current length of the selected representation. | planned | duplicate of 14.4-06 |
| `rfc9110-15.5.20-02` | 15.5.20 | **MUST NOT** | proxy | A proxy MUST NOT generate a 421 response. | out-of-scope | proxy-only |
| `rfc9110-15.5.22-01` | 15.5.22 | **MUST** | server | The server MUST send an Upgrade header field in a 426 response to indicate the required protocol(s). | planned | duplicate of 7.8-07 |

### status: 5xx

_3 requirement(s)._

| Test ID | § | Level | Role(s) | Requirement | Status | Notes |
|---|---|---|---|---|---|---|
| `rfc9110-15.6-01` | 15.6 | **SHOULD** | server | Except when responding to a HEAD request, the server SHOULD send a representation containing an explanation of the error situation, and whether it is a temporary or permanent condition. | planned | verify 5xx responses (e.g., /h/status/500) have non-empty body for GET |
| `rfc9110-15.6.4-01` | 15.6.4 | **MAY** | client, server | The server MAY send a Retry-After header field to suggest an appropriate amount of time for the client to wait before retrying the request. | out-of-scope | permission; Retry-After-in-503 covered by 15.5.14-02 |
| `rfc9110-15.6.6-01` | 15.6.6 | **SHOULD** | server | The server SHOULD generate a representation for the 505 response that describes why that version is not supported and what other protocols are supported by that server. | planned | send HTTP/9.x request → stallion emits 505 with explanatory representation |

## Appendix: client-only requirements

Captured for completeness. Relevant if stallion grows a client (e.g. via [courier](https://github.com/ponylang/courier)) or a test-fixture client. Otherwise, skim and ignore.

| Test ID | § | Level | Role(s) | Requirement |
|---|---|---|---|---|
| `rfc9110-4.2.2-03` | 4.2.2 | **MUST** | client | A client MUST ensure that its HTTP requests for an "https" resource are secured, prior to being communicated, and that it only accepts secured responses to those requests. |
| `rfc9110-4.3.4-02` | 4.3.4 | **MUST** | client | In general, a client MUST verify the service identity using the verification process defined in Section 6 of RFC6125. |
| `rfc9110-4.3.4-03` | 4.3.4 | **MUST** | client | The client MUST construct a reference identity from the service's host. |
| `rfc9110-4.3.4-04` | 4.3.4 | **MUST NOT** | client | A reference identity of type CN-ID MUST NOT be used by clients. |
| `rfc9110-4.3.4-05` | 4.3.4 | **MUST** | user agent | If the certificate is not valid for the target URI's origin, a user agent MUST either obtain confirmation from the user before proceeding or terminate the connection with a bad certificate error. |
| `rfc9110-4.3.4-06` | 4.3.4 | **MUST** | client | Automated clients MUST log the error to an appropriate audit log (if available) and SHOULD terminate the connection (with a bad certificate error). |
| `rfc9110-4.3.4-07` | 4.3.4 | **MUST** | client | Automated clients MAY provide a configuration setting that disables this check, but MUST provide a setting which enables it. |
| `rfc9110-5.4-02` | 5.4 | **MAY** | client | A client MAY discard or truncate received field lines that are larger than the client wishes to process if the field semantics are such that the dropped value(s) can be safely ignored without changing the message framing or response semantics. |
| `rfc9110-6-01` | 6 | **MUST** | client | A client MUST retain knowledge of the request when parsing, interpreting, or caching a corresponding response. |
| `rfc9110-6.2-02` | 6.2 | **MUST NOT** | client | A client MUST NOT send a version to which it is not conformant. |
| `rfc9110-7.2-01` | 7.2 | **MUST** | user agent | A user agent MUST generate a Host header field in a request unless it sends that information as an ":authority" pseudo-header field. |
| `rfc9110-7.2-02` | 7.2 | **SHOULD** | user agent | A user agent that sends Host SHOULD send it as the first field in the header section of a request. |
| `rfc9110-7.5-01` | 7.5 | **SHOULD** | client | A client that receives a response while it is still sending the associated request SHOULD continue sending that request unless it receives an explicit indication to the contrary. |
| `rfc9110-8.6-01` | 8.6 | **SHOULD** | user agent | A user agent SHOULD send Content-Length in a request when the method defines a meaning for enclosed content and it is not sending Transfer-Encoding. |
| `rfc9110-8.6-02` | 8.6 | **SHOULD NOT** | user agent | A user agent SHOULD NOT send a Content-Length header field when the request message does not contain content and the method semantics do not anticipate such data. |
| `rfc9110-9.2.1-01` | 9.2.1 | **SHOULD** | user agent | A user agent SHOULD distinguish between safe and unsafe methods when presenting potential actions to a user, such that the user can be made aware of an unsafe action before it is requested. |
| `rfc9110-9.2.2-01` | 9.2.2 | **SHOULD NOT** | client | A client SHOULD NOT automatically retry a request with a non-idempotent method unless it has some means to know that the request semantics are actually idempotent, regardless of the method, or some means to detect that the original request was never applied. |
| `rfc9110-9.2.2-03` | 9.2.2 | **SHOULD NOT** | client | A client SHOULD NOT automatically retry a failed automatic retry. |
| `rfc9110-9.3.4-07` | 9.3.4 | **SHOULD** | client | A service that selects a proper URI on behalf of the client, after receiving a state-changing request, SHOULD be implemented using the POST method rather than PUT. |
| `rfc9110-9.3.6-01` | 9.3.6 | **MUST** | client | A client MUST send the port number even if the CONNECT request is based on a URI reference that contains an authority component with an elided port. |
| `rfc9110-9.3.6-07` | 9.3.6 | **MUST** | client | A client MUST ignore any Content-Length or Transfer-Encoding header fields received in a successful response to CONNECT. |
| `rfc9110-9.3.7-04` | 9.3.7 | **MUST** | client | A client that generates an OPTIONS request containing content MUST send a valid Content-Type header field describing the representation media type. |
| `rfc9110-9.3.8-02` | 9.3.8 | **MUST NOT** | client | A client MUST NOT generate fields in a TRACE request containing sensitive data that might be disclosed by the response. |
| `rfc9110-9.3.8-04` | 9.3.8 | **MUST NOT** | client | A client MUST NOT send content in a TRACE request. |
| `rfc9110-10.1.1-02` | 10.1.1 | **MUST NOT** | client | A client MUST NOT generate a 100-continue expectation in a request that does not include content. |
| `rfc9110-10.1.1-03` | 10.1.1 | **MUST** | client | A client that will wait for a 100 (Continue) response before sending the request content MUST send an Expect header field containing a 100-continue expectation. |
| `rfc9110-10.1.1-04` | 10.1.1 | **MAY** | client | A client that sends a 100-continue expectation is not required to wait for any specific length of time; such a client MAY proceed to send the content even if it has not yet received a response. |
| `rfc9110-10.1.1-06` | 10.1.1 | **SHOULD** | client | A client that receives a 417 (Expectation Failed) status code in response to a request containing a 100-continue expectation SHOULD repeat that request without a 100-continue expectation. |
| `rfc9110-10.1.2-01` | 10.1.2 | **SHOULD NOT** | user agent | A user agent SHOULD NOT send a From header field without explicit configuration by the user, since that might conflict with the user's privacy interests or their site's security policy. |
| `rfc9110-10.1.3-01` | 10.1.3 | **MUST NOT** | user agent | A user agent MUST NOT include the fragment and userinfo components of the URI reference, if any, when generating the Referer field value. |
| `rfc9110-10.1.3-02` | 10.1.3 | **MUST** | user agent | If the target URI was obtained from a source that does not have its own URI, the user agent MUST either exclude the Referer header field or send it with a value of "about:blank". |
| `rfc9110-10.1.3-03` | 10.1.3 | **MAY** | user agent | The Referer header field value need not convey the full URI of the referring resource; a user agent MAY truncate parts other than the referring origin. |
| `rfc9110-10.1.3-04` | 10.1.3 | **SHOULD NOT** | user agent | A user agent SHOULD NOT send a Referer header field if the referring resource was accessed with a secure protocol and the request target has an origin differing from that of the referring resource, unless the referring resource explicitly allows Referer to be sent. |
| `rfc9110-10.1.3-05` | 10.1.3 | **MUST NOT** | user agent | A user agent MUST NOT send a Referer header field in an unsecured HTTP request if the referring resource was accessed with a secure protocol. |
| `rfc9110-10.1.5-01` | 10.1.5 | **SHOULD** | user agent | A user agent SHOULD send a User-Agent header field in each request unless specifically configured not to do so. |
| `rfc9110-10.1.5-04` | 10.1.5 | **SHOULD NOT** | user agent | A user agent SHOULD NOT generate a User-Agent header field containing needlessly fine-grained detail and SHOULD limit the addition of subproducts by third parties. |
| `rfc9110-10.2.2-01` | 10.2.2 | **MUST** | user agent | If the Location value provided in a 3xx (Redirection) response does not have a fragment component, a user agent MUST process the redirection as if the value inherits the fragment component of the URI reference used to generate the target URI. |
| `rfc9110-12.5.4-01` | 12.5.4 | **MUST NOT** | user agent | A user agent that does not provide such control to the user MUST NOT send an Accept-Language header field. |
| `rfc9110-13.1.1-06` | 13.1.1 | **MAY** | client | A client MAY send an If-Match header field in a GET request to indicate that it would prefer a 412 (Precondition Failed) response if the selected representation does not match. |
| `rfc9110-13.1.2-03` | 13.1.2 | **SHOULD** | client | When a client desires to update one or more stored responses that have entity tags, the client SHOULD generate an If-None-Match header field containing a list of those entity tags when making a GET request. |
| `rfc9110-13.1.4-09` | 13.1.4 | **MAY** | client | A client MAY send an If-Unmodified-Since header field in a GET request to indicate that it would prefer a 412 (Precondition Failed) response if the selected representation has been modified. |
| `rfc9110-13.1.5-01` | 13.1.5 | **MUST NOT** | client | A client MUST NOT generate an If-Range header field in a request that does not contain a Range header field. |
| `rfc9110-13.1.5-04` | 13.1.5 | **MUST NOT** | client | A client MUST NOT generate an If-Range header field containing an entity tag that is marked as weak. |
| `rfc9110-13.1.5-05` | 13.1.5 | **MUST NOT** | client | A client MUST NOT generate an If-Range header field containing an HTTP-date unless the client has no entity tag for the corresponding representation and the date is a strong validator. |
| `rfc9110-14.2-06` | 14.2 | **SHOULD NOT** | client | A client SHOULD NOT request multiple ranges that are inherently less efficient to process and transfer than a single range that encompasses the same data. |
| `rfc9110-14.2-08` | 14.2 | **SHOULD** | client | A client that is requesting multiple ranges SHOULD list those ranges in ascending order unless there is a specific need to request a later part earlier. |
| `rfc9110-15-01` | 15 | **MUST** | client | A client MUST understand the class of any status code, as indicated by the first digit, and treat an unrecognized status code as being equivalent to the x00 status code of that class. |
| `rfc9110-15.2-02` | 15.2 | **MUST** | client | A client MUST be able to parse one or more 1xx responses received prior to a final response, even if the client does not expect one. |
| `rfc9110-15.2-03` | 15.2 | **MAY** | user agent | A user agent MAY ignore unexpected 1xx responses. |
| `rfc9110-15.3.7-01` | 15.3.7 | **MUST** | client | A client MUST inspect a 206 response's Content-Type and Content-Range field(s) to determine what parts are enclosed and whether additional requests are needed. |
| `rfc9110-15.3.7.2-08` | 15.3.7.2 | **MUST NOT** | client | A client that cannot process a "multipart/byteranges" response MUST NOT generate a request that asks for multiple ranges. |
| `rfc9110-15.3.7.2-10` | 15.3.7.2 | **MUST** | client | A client that receives a multipart response MUST inspect the Content-Range header field present in each body part in order to determine which range is contained in that body part. |
| `rfc9110-15.3.7.3-01` | 15.3.7.3 | **MAY** | client | A client that has received multiple partial responses to GET requests on a target resource MAY combine those responses into a larger continuous range if they share the same strong validator. |
| `rfc9110-15.3.7.3-02` | 15.3.7.3 | **MUST** | client | If the union consists of the entire range of the representation, then the client MUST process the combined response as if it were a complete 200 (OK) response, including a Content-Length header field that reflects the complete length. |
| `rfc9110-15.3.7.3-03` | 15.3.7.3 | **MUST** | client | Otherwise, the client MUST process the set of continuous ranges as an incomplete 200 (OK) response, a single 206 (Partial Content) response containing "multipart/byteranges" content, or multiple 206 (Partial Content) responses. |
| `rfc9110-15.4-01` | 15.4 | **SHOULD** | user agent | When automatically following a redirected request, the user agent SHOULD resend the original request message with appropriate modifications. |
| `rfc9110-15.4-02` | 15.4 | **SHOULD** | client | A client SHOULD detect and intervene in cyclical redirections. |
| `rfc9110-15.4.1-03` | 15.4.1 | **MAY** | user agent | The user agent MAY make a selection from that list automatically if it understands the provided media type. |
| `rfc9110-15.4.8-01` | 15.4.8 | **MUST NOT** | user agent | The user agent MUST NOT change the request method if it performs an automatic redirection to that URI. |
| `rfc9110-15.5-02` | 15.5 | **SHOULD** | user agent | User agents SHOULD display any included representation to the user. |
| `rfc9110-15.5.2-02` | 15.5.2 | **SHOULD** | user agent | If the 401 response contains the same challenge as the prior response, and the user agent has already attempted authentication at least once, then the user agent SHOULD present the enclosed representation to the user. |
| `rfc9110-15.5.4-01` | 15.5.4 | **SHOULD NOT** | client | The client SHOULD NOT automatically repeat the request with the same credentials. |
| `rfc9110-15.5.4-02` | 15.5.4 | **MAY** | client | The client MAY repeat the request with new or different credentials. |
| `rfc9110-15.5.7-02` | 15.5.7 | **MAY** | user agent | A user agent MAY automatically select the most appropriate choice from that list. |
| `rfc9110-15.5.20-01` | 15.5.20 | **MAY** | client | A client that receives a 421 (Misdirected Request) response MAY retry the request, whether or not the request method is idempotent, over a different connection. |
| `rfc9110-15.6-02` | 15.6 | **SHOULD** | user agent | A user agent SHOULD display any included representation to the user. |

---

_Generated from a curated extract of RFC 9110 section content. To regenerate, re-run the extractor against the source text._
