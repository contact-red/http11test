use "net"
use "../wire"
use "../runner"

actor TeValueSubstringMatch is WireCallback
  """
  Probes for substring-vs-token confusion in Transfer-Encoding parsing.
  RFC 9112 §6.1 defines TE as a comma-separated list of TOKENS, and
  §6.3 says "A server that receives a request message with a transfer
  coding it does not understand SHOULD respond with 501."

  We send `Transfer-Encoding: x-chunked-fake` (a token containing
  "chunked" as a substring, but not equal to "chunked") followed by a
  valid chunked-encoded empty body (`0\\r\\n\\r\\n`). A correct server
  treats `x-chunked-fake` as an unknown transfer-coding and rejects.
  A buggy server that detects "chunked" via substring match will
  enter chunked decoding mode, successfully consume the empty body,
  and respond 200 — silently accepting unknown transfer codings.

  Acceptance: the server MUST respond with a non-2xx status. A 2xx
  indicates the substring-vs-token bug.
  """
  let _reporter: Reporter
  let _test_id: String = "rfc9112-6.1-07-te-substring-match"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("POST / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nTransfer-Encoding: x-chunked-fake\r\n")
      s.append("Connection: close\r\n\r\n")
      s.append("0\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 if (code >= 400) and (code < 600) =>
      _reporter.pass(_test_id)
    | let code: U16 =>
      _reporter.fail(_test_id,
        "server accepted unknown Transfer-Encoding 'x-chunked-fake' (returned "
          + code.string()
          + ") — substring-vs-token match on 'chunked'")
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
