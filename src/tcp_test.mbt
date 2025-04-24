///|
test "client" {
  let uv = @uv.Loop::new!()
  let socket = @uv.Tcp::new!(uv)
  let addr = @uv.ip4_addr("184.24.77.179", 80)
  let mut write_error = None
  let mut read_start_error = None
  let mut read_stop_error = None
  let mut connect_error = None
  socket.connect!(addr, fn(_) {  }, fn(_, e) { connect_error = Some(e) })
  socket.write!(
    [
      b"GET / HTTP/1.1\r\n", b"Host: www.example.com\r\n", b"User-Agent: libuv-client/1.0\r\n",
      b"Connection: close\r\n", b"\r\n",
    ],
    fn(_) {  },
    fn(_, e) { write_error = Some(e) },
  )
  let buffer = @buffer.new()
  socket.read_start!(
    fn(_, _) { Bytes::make(1024, 0)[:] },
    fn(_, nread, buf) { buffer.write_bytesview(buf[:nread]) },
    fn(_, e) {
      if not(e is Errno(EOF)) {
        read_start_error = Some(e)
      }
      try {
        socket.read_stop!()
      } catch {
        e => read_stop_error = Some(e)
      }
      socket.close(fn(_) {  })
    },
  )
  uv.run!(Default)
  uv.stop()
  uv.close!()
  raise_option!(connect_error)
  raise_option!(write_error)
  raise_option!(read_start_error)
  raise_option!(read_stop_error)
  let string = @encoding.decode_lossy(encoding=UTF8, buffer.contents())
  let body = [..string.split("\r\n\r\n")][1]
  @json.inspect!([..body.split("\n")][:3], content=[
    "<!doctype html>", "<html>", "<head>",
  ])
}
