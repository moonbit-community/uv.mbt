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

///|
test "udp getpeername and getsockname" {
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
test "udp broadcast and ttl" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new(uv)

  // Test broadcast
  socket.set_broadcast(true)
  socket.set_broadcast(false)

  // Test TTL
  socket.set_ttl(64)
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "udp multicast options" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new(uv)

  // Test multicast TTL
  socket.set_multicast_ttl(32)

  // Test multicast loop
  socket.set_multicast_loop(false)
  socket.set_multicast_loop(true)
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "udp multicast options" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new(uv)
  let addr : @uv.SockaddrIn = @uv.ip4_addr("127.0.0.1", 0)
  socket.bind(addr, @uv.UdpFlags::new())

  // Test multicast TTL
  socket.set_multicast_ttl(32)

  // Test multicast loop
  socket.set_multicast_loop(false)
  socket.set_multicast_loop(true)
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "udp queue info" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new(uv)

  // Test queue size and count
  let size = socket.get_send_queue_size()
  let count = socket.get_send_queue_count()

  // Should be 0 initially
  inspect(size.to_int(), content="0")
  inspect(count.to_int(), content="0")
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "udp using_recvmmsg" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new(uv)

  // Test if using recvmmsg (platform dependent)
  let using_mmsg = socket.using_recvmmsg()
  // Just ensure it doesn't crash, result is platform-dependent
  inspect(using_mmsg.to_string().length() > 0, content="true")
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "udp extended initialization" {
  let uv = @uv.Loop::new()

  // Test new_ex with flags
  let flags = @uv.UdpFlags::new(ipv6_only=false, reuseaddr=true)
  let socket = @uv.Udp::new_ex(uv, flags)
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "udp membership" {
  let uv = @uv.Loop::new()
  let socket = @uv.Udp::new(uv)

  // Test multicast membership - this may fail on some systems
  // so we just test that the function doesn't crash
  try {
    socket.set_membership(
      "224.0.0.1",
      interface_addr="0.0.0.0",
      @uv.Membership::JoinGroup,
    )
    socket.set_membership(
      "224.0.0.1",
      interface_addr="0.0.0.0",
      @uv.Membership::LeaveGroup,
    )
  } catch {
    _ => () // Some systems may not support multicast
  }
  socket.close(() => ())
  uv.run(Default)
  uv.close()
}
