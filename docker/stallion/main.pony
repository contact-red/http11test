"""
Minimal stallion server for http11test. Listens on port 80, responds
"ok\\n" with Content-Type text/plain to any request on any path. The
shape mirrors the bandit / cowboy / hyper targets so the conformance
suite sees comparable behavior.
"""
use stallion = "stallion"
use lori = "lori"

actor Main
  new create(env: Env) =>
    let auth = lori.TCPListenAuth(env.root)
    Listener(auth, "0.0.0.0", "80", env.out)

actor Listener is lori.TCPListenerActor
  var _tcp_listener: lori.TCPListener = lori.TCPListener.none()
  let _out: OutStream
  let _config: stallion.ServerConfig
  let _server_auth: lori.TCPServerAuth

  new create(
    auth: lori.TCPListenAuth,
    host: String,
    port: String,
    out: OutStream)
  =>
    _out = out
    _server_auth = lori.TCPServerAuth(auth)
    _config = stallion.ServerConfig(host, port)
    _tcp_listener = lori.TCPListener(auth, host, port, this)

  fun ref _listener(): lori.TCPListener => _tcp_listener

  fun ref _on_accept(fd: U32): lori.TCPConnectionActor =>
    OkServer(_server_auth, fd, _config)

  fun ref _on_listening() =>
    _out.print("http11test stallion target listening on :80")

  fun ref _on_listen_failure() =>
    _out.print("failed to listen on :80")

  fun ref _on_closed() =>
    _out.print("listener closed")

actor OkServer is stallion.HTTPServerActor
  var _http: stallion.HTTPServer = stallion.HTTPServer.none()

  new create(
    auth: lori.TCPServerAuth,
    fd: U32,
    config: stallion.ServerConfig)
  =>
    _http = stallion.HTTPServer(auth, fd, this, config)

  fun ref _http_connection(): stallion.HTTPServer => _http

  fun ref on_request_complete(
    request': stallion.Request val,
    responder: stallion.Responder)
  =>
    // Per RFC 9110 §9.3.2 the application is responsible for not
    // emitting a body when the request method is HEAD. The headers
    // (including Content-Length) match what a GET would produce; only
    // the body section is suppressed.
    let body: String val = "ok\n"
    let builder = stallion.ResponseBuilder(stallion.StatusOK)
      .add_header("Content-Type", "text/plain")
      .add_header("Content-Length", body.size().string())
      .finish_headers()
    let response =
      match request'.method
      | stallion.HEAD => builder.build()
      else builder.add_chunk(body).build()
      end
    responder.respond(response)
