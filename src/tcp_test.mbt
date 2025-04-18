test "dns" {
  let uv = @uv.Loop::new!()
  
}

///|
test "client" {
  let uv = @uv.Loop::new!()
  let socket = @uv.Tcp::new!(uv)
  let addr = @uv.ip4_addr("184.24.77.179", 80)
  socket.connect!(addr, fn(_) {  }, fn(_, e) { println("Error: \{e}") })
  socket.write!(
    [
      b"GET / HTTP/1.1\r\n", b"Host: www.example.com\r\n", b"User-Agent: libuv-client/1.0\r\n",
      b"Connection: close\r\n", b"\r\n",
    ],
    fn(_) {  },
    fn(_, e) { println("Error: \{e}") },
  )
  let buffer = @buffer.new()
  socket.read_start!(
    fn(_, _) { Bytes::make(1024, 0)[:] },
    fn(_, nread, buf) { buffer.write_bytesview(buf[:nread]) },
    fn(_, e) {
      if not(e is Errno(EOF)) {
        println("Error: \{e}")
      }
      socket.close(fn(_) {  })
    },
  )
  uv.run!(Default)
  uv.stop()
  uv.close!()
  let string = @encoding.decoder(UTF8).decode_lossy(buffer.contents())
  let body = [..string.split("\r\n\r\n")][1]
  @json.inspect!([..body.split("\n")][:3], content=[
    "<!doctype html>", "<html>", "<head>",
  ])
}
