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
type Tcp

///|
pub impl ToHandle for Tcp with to_handle(self : Tcp) -> Handle = "%identity"

///|
pub impl ToHandle for Tcp with of_handle(self : Handle) -> Tcp = "%identity"

///|
pub impl ToStream for Tcp with to_stream(self : Tcp) -> Stream = "%identity"

///|
pub impl ToStream for Tcp with of_stream(self : Stream) -> Tcp = "%identity"

///|
extern "c" fn uv_tcp_make() -> Tcp = "moonbit_uv_tcp_make"

///|
#owned(uv, tcp)
extern "c" fn uv_tcp_init(uv : Loop, tcp : Tcp) -> Int = "moonbit_uv_tcp_init"

///|
pub fn Tcp::new(uv : Loop) -> Tcp raise Errno {
  let tcp = uv_tcp_make()
  let result = uv_tcp_init(uv, tcp)
  if result < 0 {
    raise Errno::of_int(result)
  }
  tcp
}

///|
#owned(tcp, os_sock)
extern "c" fn uv_tcp_open(tcp : Tcp, os_sock : OsSock) -> Int = "moonbit_uv_tcp_open"

///|
pub fn Tcp::open(self : Tcp, os_sock : OsSock) -> Unit raise Errno {
  let status = uv_tcp_open(self, os_sock)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(tcp, addr)
extern "c" fn uv_tcp_bind(tcp : Tcp, addr : Sockaddr, flags : UInt) -> Int = "moonbit_uv_tcp_bind"

///|
struct TcpBindFlags(UInt)

///|
const TCP_IPV6ONLY : UInt = 1

///|
const TCP_REUSEPORT : UInt = 2

///|
pub fn TcpBindFlags::new(
  ipv6_only? : Bool = false,
  reuse_port? : Bool = false,
) -> TcpBindFlags {
  let mut flags = 0U
  if ipv6_only {
    flags = flags | TCP_IPV6ONLY
  }
  if reuse_port {
    flags = flags | TCP_REUSEPORT
  }
  return flags
}

///|
/// Bind the handle to an address and port.
///
/// When the port is already taken, you can expect to see an `UV_EADDRINUSE`
/// error from `uv_listen()` or `uv_tcp_connect()` unless you specify
/// `UV_TCP_REUSEPORT` in flags for all the binding sockets. That is, a
/// successful call to this function does not guarantee that the call to
/// `uv_listen()` or `uv_tcp_connect()` will succeed as well.
///
/// PARAMETERS:
///
///   - handle – TCP handle. It should have been initialized with
///     `uv_tcp_init()`.
///   - addr – Address to bind to. It should point to an initialized
///     `SockaddrIn` or `SockaddrIn6`.
///   - flags – Flags that control the behavior of binding the socket.
///     `UV_TCP_IPV6ONLY` can be contained in flags to disable dual-stack
///     support and only use IPv6. `UV_TCP_REUSEPORT` can be contained in flags
///     to enable the socket option `SO_REUSEPORT` with the capability of load
///     balancing that distribute incoming connections across all listening
///     sockets in multiple processes or threads.
///
/// RETURNS:
///
///   0 on success, or an error code < 0 on failure.
///
/// *Changed in version 1.49.0*: added the `UV_TCP_REUSEPORT` flag.
pub fn[Sockaddr : ToSockaddr] Tcp::bind(
  self : Tcp,
  addr : Sockaddr,
  flags : TcpBindFlags,
) -> Unit raise Errno {
  let status = uv_tcp_bind(self, addr.to_sockaddr(), flags.0)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(req, handle, addr)
extern "c" fn uv_tcp_connect(
  req : Connect,
  handle : Tcp,
  addr : Sockaddr,
  cb : (Connect, Int) -> Unit,
) -> Int = "moonbit_uv_tcp_connect"

///|
pub fn[Sockaddr : ToSockaddr] Tcp::connect(
  self : Tcp,
  addr : Sockaddr,
  connect_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Connect raise Errno {
  fn cb(_ : Connect, status : Int) {
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      connect_cb()
    }
  }

  let req = uv_connect_make()
  let status = uv_tcp_connect(req, self, addr.to_sockaddr(), cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
#owned(tcp)
extern "c" fn uv_tcp_nodelay(tcp : Tcp, enable : Bool) -> Int = "moonbit_uv_tcp_nodelay"

///|
/// Enable `TCP_NODELAY`, which disables Nagle’s algorithm.
pub fn Tcp::nodelay(self : Tcp, enable : Bool) -> Unit raise Errno {
  let status = uv_tcp_nodelay(self, enable)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(tcp)
extern "c" fn uv_tcp_keepalive(tcp : Tcp, enable : Bool, delay : UInt) -> Int = "moonbit_uv_tcp_keepalive"

///|
/// Enable / disable TCP keep-alive. delay is the initial delay in seconds,
/// ignored when enable is zero.
///
/// After delay has been reached, 10 successive probes, each spaced 1 second
/// from the previous one, will still happen. If the connection is still lost at
/// the end of this procedure, then the handle is destroyed with a
/// `UV_ETIMEDOUT` error passed to the corresponding callback.
///
/// If _delay_ is less than 1 then `UV_EINVAL` is returned.
///
/// *Changed in version 1.49.0*: If _delay_ is less than 1 then `UV_EINVAL` is returned.
pub fn Tcp::keepalive(
  self : Tcp,
  enable : Bool,
  delay? : UInt = 0U,
) -> Unit raise Errno {
  let status = uv_tcp_keepalive(self, enable, delay)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(tcp)
extern "c" fn uv_tcp_keepalive_ex(
  tcp : Tcp,
  on : Bool,
  idle : UInt,
  interval : UInt,
  count : UInt,
) -> Int = "moonbit_uv_tcp_keepalive_ex"

///|
/// Enable / disable TCP keep-alive with all socket options: `TCP_KEEPIDLE`,
/// `TCP_KEEPINTVL` and `TCP_KEEPCNT`. `idle` is the value for `TCP_KEEPIDLE`,
/// `intvl` is the value for `TCP_KEEPINTVL`, `cnt` is the value for `TCP_KEEPCNT`, ignored when `on` is zero.
///
/// With TCP keep-alive enabled, idle is the time (in seconds) the connection needs to remain idle before TCP starts sending keep-alive probes. intvl is the time (in seconds) between individual keep-alive probes. TCP will drop the connection after sending cnt probes without getting any replies from the peer, then the handle is destroyed with a UV_ETIMEDOUT error passed to the corresponding callback.
///
/// If one of idle, intvl, or cnt is less than 1, UV_EINVAL is returned.
pub fn Tcp::keepalive_ex(
  self : Tcp,
  on : Bool,
  idle~ : UInt,
  interval~ : UInt,
  count~ : UInt,
) -> Unit raise Errno {
  if idle < 1U || interval < 1U || count < 1U {
    raise Errno::EINVAL
  }
  let status = uv_tcp_keepalive_ex(self, on, idle, interval, count)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(tcp, addr)
extern "c" fn uv_tcp_getsockname(tcp : Tcp, addr : Sockaddr) -> Int = "moonbit_uv_tcp_getsockname"

///|
/// Get the current address to which the handle is bound.
/// `struct sockaddr_storage` is used for IPv4 and IPv6 support.
pub fn Tcp::getsockname(self : Tcp) -> Sockaddr raise Errno {
  let addr = uv_sockaddr_make()
  let status = uv_tcp_getsockname(self, addr)
  if status < 0 {
    raise Errno::of_int(status)
  }
  addr
}

///|
#owned(tcp, addr)
extern "c" fn uv_tcp_getpeername(tcp : Tcp, addr : Sockaddr) -> Int = "moonbit_uv_tcp_getpeername"

///|
/// Get the address of the peer connected to the handle.
/// `struct sockaddr_storage` is used for IPv4 and IPv6 support.
pub fn Tcp::getpeername(self : Tcp) -> Sockaddr raise Errno {
  let addr = uv_sockaddr_make()
  let status = uv_tcp_getpeername(self, addr)
  if status < 0 {
    raise Errno::of_int(status)
  }
  addr
}

///|
#owned(tcp)
extern "c" fn uv_tcp_close_reset(tcp : Tcp, cb : () -> Unit) -> Int = "moonbit_uv_tcp_close_reset"

///|
/// Resets a TCP connection by sending a RST packet. This is accomplished by
/// setting the `SO_LINGER` socket option with a linger interval of zero and
/// then calling `uv_close()`. Due to some platform inconsistencies, mixing of
/// `uv_shutdown()` and `uv_tcp_close_reset()` calls is not allowed.
///
/// *New in version 1.32.0.*
pub fn Tcp::close_reset(self : Tcp, close_cb : () -> Unit) -> Unit raise Errno {
  let status = uv_tcp_close_reset(self, close_cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(tcp)
extern "c" fn uv_tcp_simultaneous_accepts(tcp : Tcp, enable : Bool) -> Int = "moonbit_uv_tcp_simultaneous_accepts"

///|
/// Enable / disable simultaneous asynchronous accept requests that are queued
/// by the operating system when listening for new TCP connections.
///
/// This setting is used to tune a TCP server for the desired performance.
/// Having simultaneous accepts can significantly improve the rate of accepting
/// connections (which is why it is enabled by default) but may lead to uneven
/// load distribution in multi-process setups.
pub fn Tcp::simultaneous_accepts(self : Tcp, enable : Bool) -> Unit raise Errno {
  let status = uv_tcp_simultaneous_accepts(self, enable)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
