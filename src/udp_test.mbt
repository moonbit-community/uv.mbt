///|
test "udp" {
  let uv = @uv.Loop::new()
  let mut error : Error? = None
  let in_socket = @uv.Udp::new(uv)
  let out_socket = @uv.Udp::new(uv)
  let addr : @uv.SockaddrIn = @uv.ip4_addr("127.0.0.1", 8543)
  in_socket.bind(addr, @uv.UdpFlags::new())
  in_socket.recv_start(
    fn(_, _) { Bytes::make(100, 0)[:] },
    fn(_, nread, data, _, _) {
      assert_eq(data[:nread], b"Hello World!") catch {
        e => {
          error = Some(e)
          in_socket.close(fn(_) {  })
        }
      }
      in_socket.close(fn(_) {  })
    },
    fn(_, errno) {
      error = Some(errno)
      in_socket.close(fn(_) {  })
    },
  )
  out_socket.send(
    [b"Hello World!"],
    fn(_) { out_socket.close(fn(_) {  }) },
    fn(_, e) {
      error = Some(e)
      out_socket.close(ignore)
    },
    addr~,
  )
  uv.run(Default)
  uv.close()
  if error is Some(e) {
    raise e
  }
}
