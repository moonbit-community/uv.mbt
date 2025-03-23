///|
fn main {
  let uv = @uv.loop_alloc()
  @uv.loop_init(uv) |> ignore()
  let server = @uv.tcp_alloc()
  @uv.tcp_init(uv, server) |> ignore()
  let addr = @uv.sockaddr_in_alloc()
  @uv.ip4_addr(b"127.0.0.1\x00", 7001, addr)
  let connect = @uv.connect_alloc()
  let tty_read_buf = Bytes::make(1024, 0)
  let tty_read_iov = @uv.buf_alloc()
  @uv.buf_init(tty_read_iov, tty_read_buf, 0, tty_read_buf.length())
  let tty_read_req = @uv.fs_alloc()
  let tty_write_iov = @uv.buf_alloc()
  let tty_write_req = @uv.fs_alloc()
  let tcp_write_req = @uv.write_alloc()
  fn on_connect(_ : @uv.Connect, status : Int) {
    if status < 0 {
      println("Connect error: \{@uv.strerror(status)}")
      return
    }
    @uv.fs_read(uv, tty_read_req, 0, [tty_read_iov], -1, on_stdin_read)
    |> ignore()
    @uv.read_start(server.to_stream(), alloc_buffer, on_tcp_read) |> ignore()
  }

  fn on_close(_ : @uv.Handle) {
    @uv.fs_req_cleanup(tty_read_req)
  }

  fn alloc_buffer(_ : @uv.Handle, suggested_size : UInt64, buf : @uv.Buf) {
    let suggested_size = suggested_size.to_int()
    @uv.buf_init(buf, Bytes::make(suggested_size, 0), 0, suggested_size)
  }

  fn on_tcp_write(_ : @uv.Write, status : Int) {
    println("Write status: \{status}")
    if status != 0 {
      println("Write error: \{@uv.strerror(status)}")
    }
  }

  fn on_stdin_read(req : @uv.Fs) {
    let n_read = @uv.fs_get_result(req).to_int()
    println("Read \{n_read} bytes from stdin")
    if n_read > 0 {
      @uv.buf_set_len(tty_read_iov, n_read.to_uint64())
      @uv.write(tcp_write_req, server.to_stream(), [tty_read_iov], on_tcp_write)
      |> ignore()
    }
    if n_read < 0 {
      if n_read != @uv.EOF {
        println("Read error: \{@uv.strerror(n_read)}")
      } else {
        println("EOF")
      }
      @uv.close(server.to_handle(), on_close)
    }
  }

  fn on_stdout_write(req : @uv.Fs) {
    let result = @uv.fs_get_result(req)
    println("Wrote \{result} bytes to stdout")
    if result < 0 {
      println("Write error: \{@uv.strerror(result.to_int())}")
    }
  }

  fn on_tcp_read(server : @uv.Stream, n_read : Int64, buf : @uv.Buf) {
    let n_read = n_read.to_int()
    if n_read > 0 {
      let bytes = @uv.buf_get_base(buf)
      @uv.buf_init(tty_write_iov, bytes, 0, n_read)
      @uv.fs_write(uv, tty_write_req, 1, [tty_write_iov], -1, on_stdout_write)
      |> ignore()
    }
    if n_read < 0 {
      if n_read != @uv.EOF {
        println("Read error: \{@uv.strerror(n_read)}")
      }
      @uv.close(server.to_handle(), on_close)
    }
  }

  @uv.tcp_connect(connect, server, addr.to_sockaddr(), on_connect) |> ignore()
  @uv.run(uv, @uv.RunMode::Default) |> ignore()
}
