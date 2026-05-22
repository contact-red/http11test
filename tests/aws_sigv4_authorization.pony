use "net"
use "../wire"
use "../runner"

actor AwsSigv4Authorization is WireCallback
  """
  AWS Signature V4 auth header — long, structured, contains commas
  and equals signs. Server should accept the opaque value.
  """
  let _reporter: Reporter
  let _test_id: String = "aws-sigv4-1-01-authorization-header"

  new create(
    auth: TCPConnectAuth,
    host: String,
    service: String,
    reporter: Reporter)
  =>
    _reporter = reporter

    let request = recover val
      let s = String
      s.append("GET / HTTP/1.1\r\nHost: ")
      s.append(host)
      s.append("\r\nAuthorization: AWS4-HMAC-SHA256 ")
      s.append("Credential=AKIAIOSFODNN7EXAMPLE/20260521/us-east-1/s3/aws4_request, ")
      s.append("SignedHeaders=host;x-amz-date, ")
      s.append("Signature=fe5f80f77d5fa3beca038a248ff027d0445342fe2855ddc963176630326f1024\r\n")
      s.append("x-amz-date: 20260521T123456Z\r\n")
      s.append("Connection: close\r\n\r\n")
      s
    end

    WireClient(auth, host, service, request, this)

  be on_response(bytes: Array[U8] val) =>
    match ResponseParser.status_code(bytes)
    | let code: U16 =>
      if (code >= 200) and (code < 300) then
        _reporter.pass(_test_id)
      else
        _reporter.fail(_test_id,
          "AWS SigV4 returned " + code.string())
      end
    | let err: ParseError => _reporter.fail(_test_id, err.describe())
    end

  be on_error(reason: String) =>
    _reporter.fail(_test_id, reason)
