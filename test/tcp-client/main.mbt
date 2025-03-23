///|
fn main {
  let uv = @uv.loop_alloc()
  @uv.loop_init(uv) |> ignore()
  fn alloc_buffer(_ : @uv.Handle, suggested_size : UInt64, buf : @uv.Buf) {
    let suggested_size = suggested_size.to_int()
    @uv.buf_init(buf, Bytes::make(suggested_size, 0), suggested_size)
  }

  fn on_tcp_write(_ : @uv.Write, status : Int) {
    println("Write status: \{status}")
    if status != 0 {
      println("Write error: \{@uv.strerror(status)}")
    }
  }

  fn on_tty_write(req : @uv.Fs) {
    let result = @uv.fs_get_result(req)
    if result < 0 {
      println("Write error: \{@uv.strerror(result.to_int())}")
    }
  }

  fn on_tcp_close(_ : @uv.Handle) {

  }

  fn on_tty_close(_ : @uv.Handle) {

  }

  let server = @uv.tcp_alloc()
  @uv.tcp_init(uv, server) |> ignore()
  let stdin = @uv.tty_alloc()
  @uv.tty_init(uv, stdin, @uv.STDIN) |> ignore()
  fn on_tty_read(_ : @uv.Stream, nread : Int64, buf : @uv.Buf) {
    let nread = nread.to_int()
    if nread > 0 {
      let write = @uv.write_alloc()
      let write_buf = @uv.buf_alloc()
      @uv.buf_init(write_buf, @uv.buf_get_base(buf), nread)
      @uv.write(write, server.to_stream(), [write_buf], on_tcp_write)
      |> ignore()
      return
    }
    if nread < 0 {
      if nread != @uv.EOF {
        println("Read error: \{@uv.strerror(nread)}")
      }
      @uv.read_stop(server.to_stream()) |> ignore()
      @uv.close(server.to_handle(), on_tcp_close) |> ignore()
      @uv.read_stop(stdin.to_stream()) |> ignore()
      @uv.close(stdin.to_stream().to_handle(), on_tty_close) |> ignore()
      @uv.stop(uv) |> ignore()
    }
  }

  fn on_tcp_read(server : @uv.Stream, n_read : Int64, buf : @uv.Buf) {
    let n_read = n_read.to_int()
    if n_read > 0 {
      let write_req = @uv.fs_alloc()
      let write_buf = @uv.buf_alloc()
      @uv.buf_init(write_buf, @uv.buf_get_base(buf), n_read)
      @uv.fs_write(uv, write_req, @uv.STDOUT, [write_buf], -1, on_tty_write)
      |> ignore()
      return
    }
    if n_read < 0 {
      if n_read != @uv.EOF {
        println("Read error: \{@uv.strerror(n_read)}")
      }
      @uv.read_stop(server) |> ignore()
      @uv.close(server.to_handle(), on_tcp_close)
      @uv.read_stop(stdin.to_stream()) |> ignore()
      @uv.close(stdin.to_stream().to_handle(), on_tty_close)
      @uv.stop(uv) |> ignore()
    }
  }

  fn on_connect(_ : @uv.Connect, status : Int) {
    if status < 0 {
      println("Connect error: \{@uv.strerror(status)}")
      return
    }
    @uv.read_start(server.to_stream(), alloc_buffer, on_tcp_read) |> ignore()
    @uv.read_start(stdin.to_stream(), alloc_buffer, on_tty_read) |> ignore()
  }

  let addr = @uv.sockaddr_in_alloc()
  @uv.ip4_addr(b"127.0.0.1\x00", 7001, addr)
  let connect = @uv.connect_alloc()
  @uv.tcp_connect(connect, server, addr.to_sockaddr(), on_connect) |> ignore()
  @uv.run(uv, @uv.RunMode::Default) |> ignore()
}
