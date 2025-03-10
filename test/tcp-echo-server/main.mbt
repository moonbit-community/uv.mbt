///|
fn main {
  try {
    @uv.start!(fn(uv) {
      let args = @sys.get_cli_args()
      guard args is [_, host, port] else {
        println("Usage: \{args[0]} <host> <port>")
        return
      }
      let port = @strconv.parse_int!(port)
      let server = uv.tcp!()
      let addr = @uv.ip4_addr(host, port)
      server.bind!(addr, 0)
      println("listening at \{host}:\{port}")
      server.listen!!(128)
      while true {
        let client = server.accept!()
        read~: loop client.read!!() {
          [] => break
          bytes =>
            write~: loop client.write!!(bytes) {
              [] => continue read~ client.read!!()
              bytes => continue write~ client.write!!(bytes)
            }
        }
      }
    })
  } catch {
    error => println("Errno: \{error}")
  }
}
