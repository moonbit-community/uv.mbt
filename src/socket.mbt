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
pub suberror InvalidAddressFamily Int derive(Show, ToJson)

///|
pub(all) enum AddressFamily {
  Inet
  Inet6
}

///|
fn AddressFamily::to_int(self : AddressFamily) -> Int {
  match self {
    Inet => @inet.family
    Inet6 => @inet6.family
  }
}

///|
pub typealias @socket.Sockaddr

///|
fn @socket.Sockaddr::to_json(self : @socket.Sockaddr) -> Json {
  if @inet.Sockaddr::of_sockaddr(self) is Some(sockaddr_in) {
    {
      "family": "INET",
      "addr": sockaddr_in.addr().to_json(),
      "port": sockaddr_in.port().to_json(),
    }
  } else if @inet6.Sockaddr::of_sockaddr(self) is Some(sockaddr_in6) {
    {
      "family": "INET6",
      "addr": sockaddr_in6.addr().to_json(),
      "port": sockaddr_in6.port().to_json(),
      "scope_id": sockaddr_in6.scope_id().to_json(),
    }
  } else {
    { "family": self.family().to_json() }
  }
}

///|
pub typealias @inet.Sockaddr as SockaddrIn

///|
pub typealias @inet.Addr as InAddr

///|
pub typealias @inet6.Addr as In6Addr

///|
pub trait ToSockaddr: @socket.ToSockaddr {
  ip_name(self : Self) -> Bytes raise Errno
}

///|
pub fn[T : ToSockaddr] ip_name(sockaddr : T) -> Bytes raise Errno {
  sockaddr.ip_name()
}

///|
const INET6_ADDRSTRLEN : Int = 46

///|
#borrow(src, dst)
extern "c" fn uv_inet_ntop(src : UInt, dst : FixedArray[Byte]) -> Int = "moonbit_uv_inet_ntop"

///|
pub fn inet_ntop(in_addr : @inet.Addr) -> Bytes raise Errno {
  let dst : FixedArray[Byte] = FixedArray::make(@inet.AddrStrLen, 0)
  let status = uv_inet_ntop(in_addr.0, dst)
  if status < 0 {
    raise Errno::of_int(status)
  }
  let len = for i in 0..<@inet.AddrStrLen {
    if dst[i] == 0 {
      break i
    }
  } else {
    @inet.AddrStrLen
  }
  let buf : FixedArray[Byte] = FixedArray::make(len, 0)
  buf.unsafe_blit(0, dst, 0, len)
  buf.unsafe_reinterpret_as_bytes()
}

///|
#borrow(src, dst)
extern "c" fn uv_inet_pton(src : Bytes, dst : Ref[@inet.Addr]) -> Int = "moonbit_uv_inet_pton"

///|
pub fn inet_pton(src : Bytes) -> @inet.Addr raise Errno {
  let dst = Ref::new(@inet.addr(0, 0, 0, 0))
  let status = uv_inet_pton(src, dst)
  if status < 0 {
    raise Errno::of_int(status)
  }
  dst.val
}

///|
#borrow(src, dst)
extern "c" fn uv_inet6_ntop(src : In6Addr, dst : FixedArray[Byte]) -> Int = "moonbit_uv_inet6_ntop"

///|
#borrow(src, dst)
extern "c" fn uv_inet6_pton(src : Bytes, dst : In6Addr) -> Int = "moonbit_uv_inet6_pton"

///|
pub fn inet6_ntop(in6_addr : In6Addr) -> Bytes {
  let dst : FixedArray[Byte] = FixedArray::make(INET6_ADDRSTRLEN, 0)
  let _ = uv_inet6_ntop(in6_addr, dst)
  let len = for i in 0..<dst.length() {
    if dst[i] == 0 {
      break i
    }
  } else {
    dst.length()
  }
  Bytes::from_fixedarray(dst, len~)
}

///|
pub fn inet6_pton(src : Bytes) -> In6Addr raise Errno {
  let dst = In6Addr::new(0, 0, 0, 0, 0, 0, 0, 0)
  let status = uv_inet6_pton(src, dst)
  if status < 0 {
    raise Errno::of_int(status)
  }
  dst
}

///|
pub typealias @inet6.Sockaddr as SockaddrIn6

///|
type OsSock

///|
extern "c" fn uv_os_sock_make() -> OsSock = "moonbit_uv_os_sock_make"

///|
#borrow(sock)
extern "c" fn uv_os_sock_to_int(sock : OsSock) -> Int = "moonbit_uv_os_sock_to_int"

///|
pub fn OsSock::to_int(self : OsSock) -> Int {
  uv_os_sock_to_int(self)
}

///|
#owned(sock0, sock1)
extern "c" fn uv_socketpair(
  type_ : Int,
  protocol : Int,
  sock0 : OsSock,
  flags0 : Int,
  sock1 : OsSock,
  flags1 : Int,
) -> Int = "moonbit_uv_socketpair"

///|
pub fn socketpair(
  type_ : @socket.Type,
  protocol? : Protocol,
  flags : (PipeFlags, PipeFlags),
) -> (OsSock, OsSock) raise Errno {
  let protocol = match protocol {
    Some(p) => p.to_int()
    None => 0
  }
  let socks = (uv_os_sock_make(), uv_os_sock_make())
  let status = uv_socketpair(
    type_.to_int(),
    protocol,
    socks.0,
    flags.0.0,
    socks.1,
    flags.1.0,
  )
  if status < 0 {
    raise Errno::of_int(status)
  }
  return socks
}
