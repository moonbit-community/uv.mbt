///|
fn main {
  try {
    @async.run!(fn(loop_) {
      let args = @async.args()
      if args.length() != 3 {
        let exec_name = @encoding.decoder(UTF8).decode!(args[0])
        println("Usage: \{exec_name} <host> <port>")
        return
      }
      let host_bytes = args[1]
      let port_bytes = args[2]
      let host = @encoding.decoder(UTF8).decode!(host_bytes)
      let port = @strconv.parse_int!(
        @encoding.decoder(UTF8).decode!(port_bytes),
      )
      let server = loop_.tcp!()
      let addr = @async.ip4_addr(host_bytes, port)
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
