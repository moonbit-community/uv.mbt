///|
fn[Tcp] alloc_buffer(_ : Tcp, suggested_size : Int) -> @bytes.View {
  let suggested_size = suggested_size
  Bytes::make(suggested_size, 0)[:]
}

///|
fn main {
  try {
    let uv = @uv.Loop::new()
    let server = @uv.Tcp::new(uv)
    let stdin = @uv.Tty::new(uv, @uv.stdin())
    fn on_tty_read(count : Int, bytes : @bytes.View) {
      try
        server.write([bytes[:count]], fn(_) {  }, fn(_, error) {
          println("Write error: \{error}")
        }) catch {
        error => println("Write error: \{error}")
      }
    }

    fn on_tcp_read(count : Int, bytes : @bytes.View) {
      try
        uv.fs_write(@uv.stdout(), [bytes[:count]], fn(_, _) {  }, fn(_, error) {
          println("Write error: \{error}")
        }) catch {
        error => println("Write error: \{error}")
      }
    }

    fn on_tcp_error(tcp : @uv.Tcp, error : @uv.Errno) {
      println("Tcp error: \{error}")
      try tcp.read_stop() catch {
        _ => ()
      }
      tcp.close(fn(_) {  })
    }

    fn on_tty_error(tty : @uv.Tty, error : @uv.Errno) {
      println("Tty error: \{error}")
      try tty.read_stop() catch {
        _ => ()
      }
      tty.close(fn(_) {  })
    }

    fn on_connect(_ : @uv.Connect) {
      try
        server.read_start(
          alloc_buffer,
          fn(_, count, bytes) { on_tcp_read(count, bytes) },
          fn(_, error) {
            if not(error is Errno(EOF)) {
              println("Read error: \{error}")
            }
            on_tcp_error(server, error)
            on_tty_error(stdin, error)
          },
        ) catch {
        error => println("Error: \{error}")
      }
      try
        stdin.read_start(
          alloc_buffer,
          fn(_, count, bytes) { on_tty_read(count, bytes) },
          fn(_, error) {
            println("Read error: \{error}")
            if not(error is @uv.Errno(EOF)) {
              println("Read error: \{error}")
            }
            on_tcp_error(server, error)
            on_tty_error(stdin, error)
          },
        ) catch {
        error => on_tcp_error(server, error)
      }
    }

    let addr = @uv.ip4_addr("127.0.0.1", 7001)
    let _ = server.connect(addr, on_connect, fn(_, error) {
      println("Connect error: \{error}")
    })
    uv.run(Default)
  } catch {
    error => println("Error: \{error}")
  }
}
