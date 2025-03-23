///|
fn main {
  struct WriteReq {
    req : @uv.Write
    buf : @uv.Buf
  }
  let default_port = 7001
  let default_backlog = 128
  let uv = @uv.loop_alloc()
  @uv.loop_init(uv) |> ignore()
  let server = @uv.tcp_alloc()
  @uv.tcp_init(uv, server) |> ignore()
  let addr = @uv.sockaddr_in_alloc()
  @uv.ip4_addr(b"0.0.0.0\x00", default_port, addr)
  @uv.tcp_bind(server, addr.to_sockaddr(), 0) |> ignore()
  fn alloc_buffer(_ : @uv.Handle, suggested_size : UInt64, buf : @uv.Buf) {
    let suggested_size = suggested_size.to_int()
    @uv.buf_init(buf, Bytes::make(suggested_size, 0), suggested_size)
  }

  fn on_close(_) {

  }

  fn echo_write(_ : @uv.Write, status : Int) {
    if status != 0 {
      println("Write error: \{@uv.strerror(status)}")
    }
  }

  fn echo_read(client : @uv.Stream, nread : Int64, buf : @uv.Buf) {
    let nread = nread.to_int()
    if nread > 0 {
      let req = WriteReq::{ req: @uv.write_alloc(), buf }
      @uv.buf_set_len(req.buf, nread.to_uint64())
      @uv.write(req.req, client, [req.buf], echo_write) |> ignore()
      return
    }
    if nread < 0 {
      if nread != @uv.EOF {
        println("Read error: \{@uv.strerror(nread)}")
      }
      @uv.close(client.to_handle(), on_close)
    }
  }

  fn on_new_connection(server, status) {
    if status < 0 {
      println("New connection error: \{@uv.strerror(status)}")
      return
    }
    let client = @uv.tcp_alloc()
    @uv.tcp_init(uv, client) |> ignore()
    if @uv.accept(server, client.to_stream()) == 0 {
      @uv.read_start(client.to_stream(), alloc_buffer, echo_read) |> ignore()
    } else {
      @uv.close(client.to_handle(), on_close)
    }
  }

  let r = @uv.listen(server.to_stream(), default_backlog, on_new_connection)
  if r != 0 {
    println("Listen error: \{@uv.strerror(r)}")
  } else {
    @uv.run(uv, @uv.RunMode::Default) |> ignore()
  }
}
