// Copyright 2026 International Digital Economy Academy
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

///|
test "Udp::getsockname" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new(uv)
  let addr : @uv.SockaddrIn = @uv.ip4_addr("127.0.0.1", 0)
  socket.bind(addr, @uv.UdpFlags::new())

  // Test getsockname
  let sockname = socket.getsockname()
  inspect(sockname.ip_name() is "127.0.0.1", content="true")
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "Udp::set_broadcast" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new_ex(
    uv,
    @uv.AddressFamily::inet(),
    @uv.UdpFlags::new(),
  )
  socket.set_broadcast(true)
  socket.set_broadcast(false)
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "Udp::set_ttl" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new_ex(
    uv,
    @uv.AddressFamily::inet(),
    @uv.UdpFlags::new(),
  )
  socket.set_ttl(64)
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "Udp::set_multicast_ttl" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new_ex(
    uv,
    @uv.AddressFamily::inet(),
    @uv.UdpFlags::new(),
  )
  socket.set_multicast_ttl(32)
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "Udp::set_multicast_loop" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new_ex(
    uv,
    @uv.AddressFamily::inet(),
    @uv.UdpFlags::new(),
  )
  socket.set_multicast_loop(false)
  socket.set_multicast_loop(true)
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "Udp::get_send_queue_size" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new(uv)
  let size = socket.get_send_queue_size()
  @assert.eq(size, 0)
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "Udp::get_send_queue_count" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new(uv)
  let count = socket.get_send_queue_count()
  @assert.eq(count, 0)
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "Udp::using_recvmmsg" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new(uv)
  let _ = socket.using_recvmmsg()
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "Udp::new_ex" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new_ex(
    uv,
    @uv.AddressFamily::inet(),
    @uv.UdpFlags::new(),
  )
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "Udp::set_membership" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new_ex(
    uv,
    @uv.AddressFamily::inet(),
    @uv.UdpFlags::new(),
  )
  try {
    socket.set_membership("224.0.0.1", "0.0.0.0", @uv.Membership::JoinGroup)
    socket.set_membership("224.0.0.1", "0.0.0.0", @uv.Membership::LeaveGroup)
  } catch {
    ENOTSUP => ()
    error => raise error
  }
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}
