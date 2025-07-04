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
              let request = @encoding.decode([..buf[:nread]], encoding=UTF8)
              inspect(request, content="Request")
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
            try {
              let response = @encoding.decode([..buf[:nread]], encoding=UTF8)
              inspect(response, content="Response")
            } catch {
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
