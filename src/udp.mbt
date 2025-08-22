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
type Udp

///|
pub impl ToHandle for Udp with to_handle(self : Udp) -> Handle = "%identity"

///|
pub impl ToHandle for Udp with of_handle(self : Handle) -> Udp = "%identity"

///|
extern "c" fn uv_udp_make() -> Udp = "moonbit_uv_udp_make"

///|
#owned(uv, udp)
extern "c" fn uv_udp_init(uv : Loop, udp : Udp) -> Int = "moonbit_uv_udp_init"

///|
pub fn Udp::new(uv : Loop) -> Udp raise Errno {
  let udp = uv_udp_make()
  let result = uv_udp_init(uv, udp)
  if result < 0 {
    raise Errno::of_int(result)
  }
  udp
}

///|
#owned(handle, addr)
extern "c" fn uv_udp_connect(handle : Udp, addr : Sockaddr) -> Int = "moonbit_uv_udp_connect"

///|
pub fn[Sockaddr : ToSockaddr] Udp::connect(
  self : Udp,
  addr : Sockaddr,
) -> Unit raise Errno {
  let result = uv_udp_connect(self, addr.to_sockaddr())
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
#owned(handle, addr)
extern "c" fn uv_udp_bind(handle : Udp, addr : Sockaddr, flags : UInt) -> Int = "moonbit_uv_udp_bind"

///|
pub fn[Sockaddr : ToSockaddr] Udp::bind(
  self : Udp,
  addr : Sockaddr,
  flags : UdpFlags,
) -> Unit raise Errno {
  let result = uv_udp_bind(self, addr.to_sockaddr(), flags.inner())
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
type UdpSend

///|
pub impl ToReq for UdpSend with to_req(self : UdpSend) -> Req = "%identity"

///|
extern "c" fn uv_udp_send_make() -> UdpSend = "moonbit_uv_udp_send_make"

///|
#owned(send, udp, bufs_base, bufs_offset, bufs_length)
extern "c" fn uv_udp_send(
  send : UdpSend,
  udp : Udp,
  bufs_base : FixedArray[Bytes],
  bufs_offset : FixedArray[Int],
  bufs_length : FixedArray[Int],
  addr : @c.Nullable[Sockaddr],
  cb : (UdpSend, Int) -> Unit,
) -> Int = "moonbit_uv_udp_send"

///|
pub fn[Sockaddr : ToSockaddr] Udp::send(
  self : Udp,
  data : Array[@bytes.View],
  send_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
  addr? : Sockaddr,
) -> UdpSend raise Errno {
  fn cb(_ : UdpSend, status : Int) {
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      send_cb()
    }
  }

  let req = uv_udp_send_make()
  let bufs_size = data.length()
  let bufs_base : FixedArray[Bytes] = FixedArray::make(bufs_size, [])
  let bufs_offset = FixedArray::make(bufs_size, 0)
  let bufs_length = FixedArray::make(bufs_size, 0)
  for i in 0..<data.length() {
    bufs_base[i] = data[i].data()
    bufs_offset[i] = data[i].start_offset()
    bufs_length[i] = data[i].length()
  }
  let result = uv_udp_send(
    req,
    self,
    bufs_base,
    bufs_offset,
    bufs_length,
    @c.Nullable::of(addr.map(Sockaddr::to_sockaddr)),
    cb,
  )
  if result < 0 {
    raise Errno::of_int(result)
  }
  return req
}

///|
#owned(udp)
extern "c" fn uv_udp_recv_start(
  udp : Udp,
  alloc_cb : (Handle, UInt64, @c.Pointer[Int], @c.Pointer[Int]) -> Bytes,
  recv_cb : (Udp, Int64, Bytes?, Int, Int, Sockaddr, UInt) -> Unit,
) -> Int = "moonbit_uv_udp_recv_start"

///|
pub fn Udp::recv_start(
  self : Udp,
  alloc_cb : (Handle, Int) -> @bytes.View,
  read_cb : (Udp, Int, @bytes.View, Sockaddr, UdpFlags) -> Unit,
  error_cb : (Udp, Errno) -> Unit,
) -> Unit raise Errno {
  fn uv_alloc_cb(
    handle : Handle,
    suggested_size : UInt64,
    buf_offset : @c.Pointer[Int],
    buf_length : @c.Pointer[Int],
  ) -> Bytes {
    let bytes = alloc_cb(handle, suggested_size.to_int())
    buf_offset[0] = bytes.start_offset()
    buf_length[0] = bytes.length()
    return bytes.data()
  }

  fn uv_recv_cb(
    udp : Udp,
    count : Int64,
    buf_data : Bytes?,
    buf_offset : Int,
    buf_length : Int,
    sockaddr : Sockaddr,
    flags : UInt,
  ) -> Unit {
    if count < 0 {
      error_cb(udp, Errno::of_int(count.to_int()))
    } else {
      read_cb(
        udp,
        count.to_int(),
        buf_data.unwrap()[buf_offset:buf_length],
        sockaddr,
        UdpFlags(flags),
      )
    }
  }

  let result = uv_udp_recv_start(self, uv_alloc_cb, uv_recv_cb)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
#owned(udp)
extern "c" fn uv_udp_recv_stop(udp : Udp) -> Int = "moonbit_uv_udp_recv_stop"

///|
pub fn Udp::recv_stop(self : Udp) -> Unit raise Errno {
  let result = uv_udp_recv_stop(self)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
struct UdpFlags(UInt)

///|
pub fn UdpFlags::new(
  ipv6_only~ : Bool = false,
  partial~ : Bool = false,
  reuse_addr~ : Bool = false,
  mmsg_chunk~ : Bool = false,
  mmsg_free~ : Bool = false,
  linux_recv_err~ : Bool = false,
  reuse_port~ : Bool = false,
  recvmmsg~ : Bool = false,
) -> UdpFlags {
  let mut flags = 0U
  if ipv6_only {
    flags = flags | UV_UDP_IPV6ONLY
  }
  if partial {
    flags = flags | UV_UDP_PARTIAL
  }
  if reuse_addr {
    flags = flags | UV_UDP_REUSEADDR
  }
  if mmsg_chunk {
    flags = flags | UV_UDP_MMSG_CHUNK
  }
  if mmsg_free {
    flags = flags | UV_UDP_MMSG_FREE
  }
  if linux_recv_err {
    flags = flags | UV_UDP_LINUX_RECVERR
  }
  if reuse_port {
    flags = flags | UV_UDP_REUSEPORT
  }
  if recvmmsg {
    flags = flags | UV_UDP_RECVMMSG
  }
  UdpFlags(flags)
}

///|
const UV_UDP_IPV6ONLY : UInt = 1

///|
const UV_UDP_PARTIAL : UInt = 2

///|
const UV_UDP_REUSEADDR : UInt = 4

///|
const UV_UDP_MMSG_CHUNK : UInt = 8

///|
const UV_UDP_MMSG_FREE : UInt = 16

///|
const UV_UDP_LINUX_RECVERR : UInt = 32

///|
const UV_UDP_REUSEPORT : UInt = 64

///|
const UV_UDP_RECVMMSG : UInt = 256

///|
pub(all) enum Membership {
  LeaveGroup
  JoinGroup
}

///|
pub fn Membership::to_int(self : Membership) -> Int {
  match self {
    LeaveGroup => 0
    JoinGroup => 1
  }
}

///|
#owned(uv, udp)
extern "c" fn uv_udp_init_ex(uv : Loop, udp : Udp, flags : UInt) -> Int = "moonbit_uv_udp_init_ex"

///|
/// Extended UDP initialization with flags
pub fn Udp::new_ex(
  uv : Loop,
  domain : AddressFamily,
  flags : UdpFlags,
) -> Udp raise Errno {
  let udp = uv_udp_make()
  let flags = domain.to_int().reinterpret_as_uint() | (flags.inner() >> 8 << 8)
  let result = uv_udp_init_ex(uv, udp, flags)
  if result < 0 {
    raise Errno::of_int(result)
  }
  udp
}

///|
#owned(udp, os_sock)
extern "c" fn uv_udp_open(udp : Udp, os_sock : OsSock) -> Int = "moonbit_uv_udp_open"

///|
/// Open UDP handle from existing socket
pub fn Udp::open(self : Udp, os_sock : OsSock) -> Unit raise Errno {
  let result = uv_udp_open(self, os_sock)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
#owned(udp, addr)
extern "c" fn uv_udp_getpeername(udp : Udp, addr : Sockaddr) -> Int = "moonbit_uv_udp_getpeername"

///|
/// Get the address of the peer connected to the UDP handle
pub fn Udp::getpeername(self : Udp) -> Sockaddr raise Errno {
  let addr = uv_sockaddr_make()
  let result = uv_udp_getpeername(self, addr)
  if result < 0 {
    raise Errno::of_int(result)
  }
  addr
}

///|
#owned(udp, addr)
extern "c" fn uv_udp_getsockname(udp : Udp, addr : Sockaddr) -> Int = "moonbit_uv_udp_getsockname"

///|
/// Get the current address to which the UDP handle is bound
pub fn Udp::getsockname(self : Udp) -> Sockaddr raise Errno {
  let addr = uv_sockaddr_make()
  let result = uv_udp_getsockname(self, addr)
  if result < 0 {
    raise Errno::of_int(result)
  }
  addr
}

///|
#owned(udp, multicast_addr, interface_addr)
extern "c" fn uv_udp_set_membership(
  udp : Udp,
  multicast_addr : Bytes,
  interface_addr : Bytes,
  membership : Int,
) -> Int = "moonbit_uv_udp_set_membership"

///|
/// Set UDP multicast group membership
pub fn Udp::set_membership(
  self : Udp,
  multicast_addr : Bytes,
  interface_addr : Bytes,
  membership : Membership,
) -> Unit raise Errno {
  let result = uv_udp_set_membership(
    self,
    multicast_addr,
    interface_addr,
    membership.to_int(),
  )
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
#owned(udp, multicast_addr, interface_addr, source_addr)
extern "c" fn uv_udp_set_source_membership(
  udp : Udp,
  multicast_addr : Bytes,
  interface_addr : Bytes,
  source_addr : Bytes,
  membership : Int,
) -> Int = "moonbit_uv_udp_set_source_membership"

///|
/// Set UDP source-specific multicast group membership
pub fn Udp::set_source_membership(
  self : Udp,
  multicast_addr : Bytes,
  interface_addr : Bytes,
  source_addr : Bytes,
  membership : Membership,
) -> Unit raise Errno {
  let result = uv_udp_set_source_membership(
    self,
    multicast_addr,
    interface_addr,
    source_addr,
    membership.to_int(),
  )
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
#owned(udp)
extern "c" fn uv_udp_set_multicast_loop(udp : Udp, on : Bool) -> Int = "moonbit_uv_udp_set_multicast_loop"

///|
/// Enable or disable multicast loopback
pub fn Udp::set_multicast_loop(self : Udp, on : Bool) -> Unit raise Errno {
  let result = uv_udp_set_multicast_loop(self, on)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
#owned(udp)
extern "c" fn uv_udp_set_multicast_ttl(udp : Udp, ttl : Int) -> Int = "moonbit_uv_udp_set_multicast_ttl"

///|
/// Set the multicast Time To Live (TTL)
pub fn Udp::set_multicast_ttl(self : Udp, ttl : Int) -> Unit raise Errno {
  let result = uv_udp_set_multicast_ttl(self, ttl)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
#owned(udp, interface_addr)
extern "c" fn uv_udp_set_multicast_interface(
  udp : Udp,
  interface_addr : Bytes,
) -> Int = "moonbit_uv_udp_set_multicast_interface"

///|
/// Set the multicast interface to use
pub fn Udp::set_multicast_interface(
  self : Udp,
  interface_addr : Bytes,
) -> Unit raise Errno {
  let result = uv_udp_set_multicast_interface(self, interface_addr)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
#owned(udp)
extern "c" fn uv_udp_set_broadcast(udp : Udp, on : Bool) -> Int = "moonbit_uv_udp_set_broadcast"

///|
/// Enable or disable broadcast mode
pub fn Udp::set_broadcast(self : Udp, on : Bool) -> Unit raise Errno {
  let result = uv_udp_set_broadcast(self, on)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
#owned(udp)
extern "c" fn uv_udp_set_ttl(udp : Udp, ttl : Int) -> Int = "moonbit_uv_udp_set_ttl"

///|
/// Set the Time To Live (TTL) for UDP packets
pub fn Udp::set_ttl(self : Udp, ttl : Int) -> Unit raise Errno {
  let result = uv_udp_set_ttl(self, ttl)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
#owned(udp, bufs_base, bufs_offset, bufs_length)
extern "c" fn uv_udp_try_send(
  udp : Udp,
  bufs_base : FixedArray[Bytes],
  bufs_offset : FixedArray[Int],
  bufs_length : FixedArray[Int],
  addr : @c.Nullable[Sockaddr],
) -> Int = "moonbit_uv_udp_try_send"

///|
/// Try to send data synchronously (non-blocking)
/// Returns the number of bytes written or a negative error code
pub fn[Sockaddr : ToSockaddr] Udp::try_send(
  self : Udp,
  data : Array[@bytes.View],
  addr? : Sockaddr,
) -> Int raise Errno {
  let bufs_size = data.length()
  let bufs_base : FixedArray[Bytes] = FixedArray::make(bufs_size, [])
  let bufs_offset = FixedArray::make(bufs_size, 0)
  let bufs_length = FixedArray::make(bufs_size, 0)
  for i in 0..<data.length() {
    bufs_base[i] = data[i].data()
    bufs_offset[i] = data[i].start_offset()
    bufs_length[i] = data[i].length()
  }
  let result = uv_udp_try_send(
    self,
    bufs_base,
    bufs_offset,
    bufs_length,
    @c.Nullable::of(addr.map(Sockaddr::to_sockaddr)),
  )
  if result < 0 {
    raise Errno::of_int(result)
  }
  result
}

///|
#owned(udp)
extern "c" fn uv_udp_using_recvmmsg(udp : Udp) -> Int = "moonbit_uv_udp_using_recvmmsg"

///|
/// Check if the UDP handle is using recvmmsg for receiving data
pub fn Udp::using_recvmmsg(self : Udp) -> Bool {
  uv_udp_using_recvmmsg(self) != 0
}

///|
#owned(udp)
extern "c" fn uv_udp_get_send_queue_size(udp : Udp) -> UInt64 = "moonbit_uv_udp_get_send_queue_size"

///|
/// Get the size of the send queue
pub fn Udp::get_send_queue_size(self : Udp) -> UInt64 {
  uv_udp_get_send_queue_size(self)
}

///|
#owned(udp)
extern "c" fn uv_udp_get_send_queue_count(udp : Udp) -> UInt64 = "moonbit_uv_udp_get_send_queue_count"

///|
/// Get the count of items in the send queue
pub fn Udp::get_send_queue_count(self : Udp) -> UInt64 {
  uv_udp_get_send_queue_count(self)
}
