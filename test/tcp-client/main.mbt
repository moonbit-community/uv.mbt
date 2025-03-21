///|
fn main {
  let args = @uv.args()
  let uv = @uv.loop_alloc()
  @uv.loop_init(uv) |> ignore()
  let server = @uv.tcp_alloc()
  @uv.tcp_init(uv, server) |> ignore()
  let addr = @uv.sockaddr_in_alloc()
  @uv.ip4_addr(b"127.0.0.1\x00", 7001, addr)
  let connect = @uv.connect_alloc()
  fn on_connect(_ : @uv.Connect, status : Int) {
    if status < 0 {
      println("Connect error: \{@uv.strerror(status)}")
      return
    }
    let tty = @uv.tty_alloc()
    @uv.tty_init(uv, tty, @uv.STDIN) |> ignore()
    @uv.read_start(tty.to_stream(), alloc_buffer, on_read) |> ignore()
  }

  fn on_close(_ : @uv.Handle) {
  }

  fn alloc_buffer(_ : @uv.Handle, suggested_size : UInt64, buf : @uv.Buf) {
    let suggested_size = suggested_size.to_int()
    @uv.buf_init(buf, Bytes::make(suggested_size, 0), 0, suggested_size)
  }

  fn on_write(_ : @uv.Write, status : Int) {
    if status != 0 {
      println("Write error: \{@uv.strerror(status)}")
    }
  }

  fn on_read(input : @uv.Stream, n_read : Int64, buf : @uv.Buf) {
    let n_read = n_read.to_int()
    if n_read > 0 {
      let req = @uv.write_alloc()
      @uv.buf_set_len(buf, n_read.to_uint64())
      @uv.write(req, server.to_stream(), [buf], on_write) |> ignore()
    }
    if n_read < 0 {
      if n_read != @uv.EOF {
        println("Read error: \{@uv.strerror(n_read)}")
      }
      @uv.close(input.to_handle(), on_close)
    }
  }

  @uv.tcp_connect(connect, server, addr.to_sockaddr(), on_connect) |> ignore()
  @uv.run(uv, @uv.RunMode::Default) |> ignore()
}
