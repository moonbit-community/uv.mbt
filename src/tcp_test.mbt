///|
test "tcp" {
  let uv = @uv.Loop::new()
  let client_socket = @uv.Tcp::new(uv)
  let server_socket = @uv.Tcp::new(uv)
  let addr = @uv.ip4_addr("127.0.0.1", 8544)
  let errors : Array[Error] = []
  server_socket.bind(addr, @uv.TcpBindFlags::new())
  fn server_close(error : Error?) {
    if error is Some(error) {
      errors.push(error)
    }
    server_socket.close(fn(_) {  })
  }

  server_socket.listen(
    128,
    fn(_) {
      try {
        let server_client_socket = @uv.Tcp::new(uv)
        @uv.accept(server_socket, server_client_socket)
        fn server_stop_read(error : Error?) {
          if error is Some(error) {
            errors.push(error)
          }
          server_client_socket.read_stop() catch {
            e => errors.push(e)
          }
          server_client_socket.close(fn(_) {  })
          server_close(None)
        }

        server_client_socket.read_start(
          fn(_, _) { Bytes::make(32, 0)[:] },
          fn(_, nread, buf) {
            try {
              let request = @encoding.decode([..buf[:nread]], encoding=UTF8)
              inspect(request, content="Request")
              server_client_socket.write(
                [b"Response"],
                fn(_) { server_stop_read(None) },
                fn(_, e) { server_stop_read(Some(e)) },
              )
            } catch {
              e => server_stop_read(Some(e))
            }
          },
          fn(_, e) {
            if e is Errno(EOF) {
              server_stop_read(None)
            } else {
              server_stop_read(Some(e))
            }
          },
        )
      } catch {
        e => server_close(Some(e))
      }
    },
    fn(_, e) { server_close(Some(e)) },
  )
  fn client_close(error : Error?) {
    if error is Some(error) {
      errors.push(error)
    }
    client_socket.close(fn(_) {  })
  }

  client_socket.connect(
    addr,
    fn(_) {
      fn client_stop_read(error : Error?) {
        if error is Some(error) {
          errors.push(error)
        }
        client_socket.read_stop() catch {
          e => errors.push(e)
        }
        client_close(None)
      }

      try {
        client_socket.write([b"Request"], fn(_) { client_close(None) }, fn(
          _,
          e
        ) {
          client_close(Some(e))
        })
        client_socket.read_start(
          fn(_, _) { Bytes::make(32, 0)[:] },
          fn(_, nread, buf) {
            try {
              let response = @encoding.decode([..buf[:nread]], encoding=UTF8)
              inspect(response, content="Response")
            } catch {
              e => client_stop_read(Some(e))
            }
          },
          fn(_, e) {
            if e is Errno(EOF) {
              client_stop_read(None)
            } else {
              client_stop_read(Some(e))
            }
          },
        )
      } catch {
        e => client_close(Some(e))
      }
    },
    fn(_, e) { client_close(Some(e)) },
  )
  uv.run(Default)
  uv.stop()
  uv.close()
  for error in errors {
    raise error
  }
}
