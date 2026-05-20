use "net"
use "runner"
use "tests"

actor Main
  new create(env: Env) =>
    let args = env.args
    if args.size() < 3 then
      env.err.print("usage: http11test <host> <service>")
      env.exitcode(2)
      return
    end

    let host = try args(1)? else "" end
    let service = try args(2)? else "80" end

    let auth = TCPConnectAuth(env.root)

    let cases: Array[RejectSpec val] val = recover val
      [ as RejectSpec val:
        UriTooLong(host)
        UnknownMethod(host)
        MissingHost(host)
        DuplicateHost(host)
        HeaderWhitespace(host)
        GarbageBytes(host)
        BareCr(host)
        ObsFold(host)
        OversizeHeader(host)
        InvalidContentLength(host)
        LeadingCrlf(host)
      ]
    end

    // Count: RejectSpec list + any custom-shape tests instantiated below.
    let reporter = Reporter(env, cases.size() + 29)

    for spec in cases.values() do
      RejectRunner(auth, host, service, spec, reporter)
    end

    HeadParityRunner(auth, host, service, reporter)
    PersistentConnectionRunner(auth, host, service, reporter)
    ConnectionCloseRunner(auth, host, service, reporter)
    ContentLengthAccuracy(auth, host, service, reporter)
    DateHeaderFormat(auth, host, service, reporter)
    PipelineOrder(auth, host, service, reporter)
    ContentTypeOnBody(auth, host, service, reporter)
    NoObsFoldInResponse(auth, host, service, reporter)
    EchoesConnectionClose(auth, host, service, reporter)
    NoBareCrInResponse(auth, host, service, reporter)
    ResponseHttpVersion(auth, host, service, reporter)
    HeadClParity(auth, host, service, reporter)
    OptionsReturnsAllow(auth, host, service, reporter)
    TraceReflects(auth, host, service, reporter)
    OptionsAsterisk(auth, host, service, reporter)
    HeadHasDate(auth, host, service, reporter)
    BrowserStyleRequest(auth, host, service, reporter)
    ContentTypeWellFormed(auth, host, service, reporter)
    ThreePersistentHeads(auth, host, service, reporter)
    GetWithQueryString(auth, host, service, reporter)
    HeadGetStatusParity(auth, host, service, reporter)
    ResponseHasFraming(auth, host, service, reporter)
    NoOwsAfterColon(auth, host, service, reporter)
    MultipleConnectionOptions(auth, host, service, reporter)
    HostWithPort(auth, host, service, reporter)
    HeadGetCtParity(auth, host, service, reporter)
    MultipleConnectionLines(auth, host, service, reporter)
    HeadGetServerParity(auth, host, service, reporter)
    AcceptWildcard(auth, host, service, reporter)
