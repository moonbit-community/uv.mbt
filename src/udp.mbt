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
extern "c" fn uv_udp_recv_stop(udp : Udp) -> Int = "moonbit_uv_udp_recv_stop"

///|
pub fn Udp::recv_stop(self : Udp) -> Unit raise Errno {
  let result = uv_udp_recv_stop(self)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
type UdpFlags UInt

///|
pub fn UdpFlags::new() -> UdpFlags {
  UdpFlags(0)
}
