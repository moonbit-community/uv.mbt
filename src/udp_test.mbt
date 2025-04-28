///|
test "udp" {
  let uv = @uv.Loop::new!()
  let in_socket = @uv.Udp::new!(uv)
  let out_socket = @uv.Udp::new!(uv)
  let addr : @uv.SockaddrIn = @uv.ip4_addr("127.0.0.1", 8543)
  in_socket.bind!(addr, @uv.UdpFlags::new())
  in_socket.recv_start!(
    fn(_udp, _size) { Bytes::make(100, '\x00')[:] },
    fn(_, nread, data, _, _) {
      guard data[:nread] is "Hello World!" else {
        println("Received unexpected data: \{data}}")
        in_socket.close(fn(_) {  })
      }
      in_socket.close(fn(_) {  })
    },
    fn(_udp, errno) {
      println("UDP Error: \{errno}")
      in_socket.close(fn(_) {  })
    },
  )
  out_socket.send!(
    [b"Hello World!"],
    fn(_) { out_socket.close(fn(_) {  }) },
    fn(_, e) {
      println("Error: \{e}")
      out_socket.close(ignore)
    },
    addr~,
  )
  uv.run!(Default)
  uv.stop()
  uv.close!()
}
