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
          in_socket.close(() => ())
        }
      }
      in_socket.close(() => ())
    },
    fn(_, errno) {
      error = Some(errno)
      in_socket.close(() => ())
    },
  )
  out_socket.send(
    [b"Hello World!"],
    fn() { out_socket.close(() => ()) },
    fn(e) {
      error = Some(e)
      out_socket.close(() => ())
    },
    addr~,
  )
  |> ignore()
  uv.run(Default)
  uv.close()
  if error is Some(e) {
    raise e
  }
}
