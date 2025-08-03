// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
    server_socket.close(() => ())
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
          server_client_socket.close(() => ())
          server_close(None)
        }

        server_client_socket.read_start(
          fn(_, _) { Bytes::make(32, 0)[:] },
          fn(_, nread, buf) {
            try {
              @assert.eq(buf[:nread], "Request")
              server_client_socket.write(
                [b"Response"],
                () => server_stop_read(None),
                e => server_stop_read(Some(e)),
              )
              |> ignore()
            } catch {
              e => server_stop_read(Some(e))
            }
          },
          fn(_, e) {
            if e is EOF {
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
    client_socket.close(() => ())
  }

  client_socket.connect(
    addr,
    fn() {
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
        client_socket.write([b"Request"], () => client_close(None), fn(e) {
          client_close(Some(e))
        })
        |> ignore()
        client_socket.read_start(
          fn(_, _) { Bytes::make(32, 0)[:] },
          fn(_, nread, buf) {
            @assert.eq(buf[:nread], "Response") catch {
              e => client_stop_read(Some(e))
            }
          },
          fn(_, e) {
            if e is EOF {
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
    fn(e) { client_close(Some(e)) },
  )
  |> ignore()
  uv.run(Default)
  uv.stop()
  uv.close()
  for error in errors {
    raise error
  }
}

///|
test "Tcp::getsockname" {
  let uv = Loop::new()
  let server = Tcp::new(uv)
  let addr = ip4_addr("127.0.0.1", 0)
  server.bind(addr, TcpBindFlags::new())
  @assert.eq(server.getsockname().ip_name(), "127.0.0.1")
  server.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "Tcp::nodelay" {
  let uv = Loop::new()
  let server = Tcp::new(uv)
  let addr = ip4_addr("127.0.0.1", 0)
  server.bind(addr, TcpBindFlags::new())
  server.nodelay(true)
  server.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "Tcp::keepalive" {
  let uv = Loop::new()
  let server = Tcp::new(uv)
  let addr = ip4_addr("127.0.0.1", 0)
  server.bind(addr, TcpBindFlags::new())
  server.keepalive(true, delay=60U)
  server.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "Tcp::close_reset" {
  let uv = Loop::new()
  let server = Tcp::new(uv)
  let addr = ip4_addr("127.0.0.1", 8545)
  let errors : Array[Error] = []
  server.bind(addr, TcpBindFlags::new())
  server.listen(
    128,
    _ => {
      let client = Tcp::new(uv) catch {
        e => {
          errors.push(e)
          server.close(() => ())
          return
        }
      }
      try {
        @uv.accept(server, client)
        client.read_start(
          (_, _) => Bytes::make(32, 0)[:],
          (_, nread, buf) => try {
            @assert.eq(buf[:nread], "Hello")
            client.close_reset(() => server.close(() => ())) catch {
              e => {
                errors.push(e)
                client.close(() => ())
                server.close(() => ())
              }
            }
          } catch {
            e => {
              errors.push(e)
              client.close(() => ())
              server.close(() => ())
            }
          },
          (_, e) => if not(e is EOF) {
            errors.push(e)
            client.read_stop() catch {
              e => errors.push(e)
            }
            client.close(() => ())
            server.close(() => ())
          } else {
            client.read_stop() catch {
              e => errors.push(e)
            }
            client.close_reset(() => ()) catch {
              e => {
                errors.push(e)
                client.close(() => ())
              }
            }
            server.close(() => ())
          },
        )
      } catch {
        e => {
          errors.push(e)
          server.close(() => ())
          client.close(() => ())
          return
        }
      }
    },
    (_, e) => {
      errors.push(e)
      server.close(() => ())
    },
  ) catch {
    e => {
      errors.push(e)
      server.close(() => ())
    }
  }
  let client = Tcp::new(uv)
  try
    client.connect(
      addr,
      () => try
        client.write(
          [b"Hello"],
          () => client.read_start(
            (_, _) => Bytes::make(32, 0)[:],
            (_, _, _) => {
              errors.push(Failure("Expect ECONNRESET"))
              client.read_stop() catch {
                e => errors.push(e)
              }
              client.close(() => ())
            },
            (_, e) => {
              if not(e is ECONNRESET) {
                errors.push(e)
              }
              client.read_stop() catch {
                e => errors.push(e)
              }
              client.close(() => ())
            },
          ) catch {
            e => {
              errors.push(e)
              client.close(() => ())
            }
          },
          e => {
            errors.push(e)
            client.close(() => ())
          },
        )
        |> ignore()
      catch {
        e => {
          errors.push(e)
          client.close(() => ())
        }
      },
      e => {
        if not(e is ECONNRESET) {
          errors.push(e)
        }
        client.close(() => ())
      },
    )
    |> ignore()
  catch {
    e => {
      errors.push(e)
      client.close(() => ())
    }
  }
  uv.run(Default)
  uv.close()
  for error in errors {
    raise error
  }
}

///|
test "Tcp::simultaneous_accepts" {
  let uv = Loop::new()
  let server = Tcp::new(uv)
  let addr = ip4_addr("127.0.0.1", 0)
  server.bind(addr, TcpBindFlags::new())
  server.simultaneous_accepts(true)
  server.simultaneous_accepts(false)
  server.close(() => ())
  uv.run(Default)
  uv.close()
}
