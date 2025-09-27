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
struct SockaddrIn(Bytes)

///|
extern "c" fn uv_sockaddr_in_make() -> SockaddrIn = "moonbit_uv_sockaddr_in_make"

///|
#borrow(addr)
extern "c" fn uv_sockaddr_in_port(addr : SockaddrIn) -> UInt = "moonbit_uv_sockaddr_in_port"

///|
pub fn SockaddrIn::port(self : SockaddrIn) -> UInt16 {
  uv_sockaddr_in_port(self)
  .reinterpret_as_int()
  .to_int16()
  .reinterpret_as_uint16()
}

///|
extern "c" fn uv_INET_ADDRSTRLEN() -> Int = "moonbit_uv_INET_ADDRSTRLEN"

///|
extern "c" fn uv_INET6_ADDRSTRLEN() -> Int = "moonbit_uv_INET6_ADDRSTRLEN"

///|
let _INET_ADDRSTRLEN : Int = uv_INET_ADDRSTRLEN()

///|
let _INET6_ADDRSTRLEN : Int = uv_INET6_ADDRSTRLEN()

///|
struct InAddr(UInt)

///|
pub fn InAddr::new(b0 : Byte, b1 : Byte, b2 : Byte, b3 : Byte) -> InAddr {
  let addr = (b0.to_uint() << 24) |
    (b1.to_uint() << 16) |
    (b2.to_uint() << 8) |
    b3.to_uint()
  InAddr(uv_ntohl(addr))
}

///|
#borrow(addr)
extern "c" fn uv_sockaddr_in_addr(addr : SockaddrIn) -> UInt = "moonbit_uv_sockaddr_in_addr"

///|
pub fn SockaddrIn::addr(self : SockaddrIn) -> InAddr {
  InAddr(uv_sockaddr_in_addr(self))
}

///|
#borrow(src, dst)
extern "c" fn uv_in_addr_ntop(src : UInt, dst : FixedArray[Byte]) -> Int = "moonbit_uv_in_addr_ntop"

///|
pub fn InAddr::ntop(self : InAddr) -> Bytes raise Errno {
  let dst : FixedArray[Byte] = FixedArray::make(_INET_ADDRSTRLEN, 0)
  let status = uv_in_addr_ntop(self.0, dst)
  if status < 0 {
    raise Errno::of_int(status)
  }
  let len = for i in 0..<_INET_ADDRSTRLEN {
    if dst[i] == 0 {
      break i
    }
  } else {
    _INET_ADDRSTRLEN
  }
  let buf : FixedArray[Byte] = FixedArray::make(len, 0)
  buf.unsafe_blit(0, dst, 0, len)
  buf.unsafe_reinterpret_as_bytes()
}

///|
#borrow(src, dst)
extern "c" fn uv_in_addr_pton(src : Bytes, dst : Ref[InAddr]) -> Int = "moonbit_uv_in_addr_pton"

///|
pub fn InAddr::pton(src : Bytes) -> InAddr raise Errno {
  let dst = Ref::new(InAddr(0))
  let status = uv_in_addr_pton(src, dst)
  if status < 0 {
    raise Errno::of_int(status)
  }
  dst.val
}

///|
#borrow(addr)
extern "c" fn uv_sockaddr_in6_port(addr : SockaddrIn6) -> UInt = "moonbit_uv_sockaddr_in6_port"

///|
pub fn SockaddrIn6::port(self : SockaddrIn6) -> UInt16 {
  uv_sockaddr_in6_port(self)
  .reinterpret_as_int()
  .to_int16()
  .reinterpret_as_uint16()
}

///|
#borrow(addr)
extern "c" fn uv_sockaddr_in6_scope_id(addr : SockaddrIn6) -> UInt = "moonbit_uv_sockaddr_in6_scope_id"

///|
pub fn SockaddrIn6::scope_id(self : SockaddrIn6) -> UInt {
  uv_sockaddr_in6_scope_id(self)
}

///|
#valtype
struct In6Addr(UInt64, UInt64)

///|
pub extern "c" fn uv_htons(value : UInt16) -> UInt16 = "moonbit_uv_htons"

///|
pub extern "c" fn uv_htonl(value : UInt) -> UInt = "moonbit_uv_htonl"

///|
pub extern "c" fn uv_htonll(value : UInt64) -> UInt64 = "moonbit_uv_htonll"

///|
pub extern "c" fn uv_ntohs(value : UInt16) -> UInt16 = "moonbit_uv_ntohs"

///|
pub extern "c" fn uv_ntohl(value : UInt) -> UInt = "moonbit_uv_ntohl"

///|
pub extern "c" fn uv_ntohll(value : UInt64) -> UInt64 = "moonbit_uv_ntohll"

///|
pub fn In6Addr::new(
  h0 : UInt16,
  h1 : UInt16,
  h2 : UInt16,
  h3 : UInt16,
  h4 : UInt16,
  h5 : UInt16,
  h6 : UInt16,
  h7 : UInt16,
) -> In6Addr {
  let high = (h0.to_uint64() << 48) |
    (h1.to_uint64() << 32) |
    (h2.to_uint64() << 16) |
    h3.to_uint64()
  let low = (h4.to_uint64() << 48) |
    (h5.to_uint64() << 32) |
    (h6.to_uint64() << 16) |
    h7.to_uint64()
  In6Addr(uv_ntohll(high), uv_ntohll(low))
}

///|
pub fn In6Addr::bytes(self : In6Addr) -> Bytes {
  let buf : FixedArray[Byte] = FixedArray::make(16, 0)
  let high = uv_htonll(self.0)
  let low = uv_htonll(self.1)
  buf[0] = (high >> 56).to_byte()
  buf[1] = (high >> 48).to_byte()
  buf[2] = (high >> 40).to_byte()
  buf[3] = (high >> 32).to_byte()
  buf[4] = (high >> 24).to_byte()
  buf[5] = (high >> 16).to_byte()
  buf[6] = (high >> 8).to_byte()
  buf[7] = high.to_byte()
  buf[8] = (low >> 56).to_byte()
  buf[9] = (low >> 48).to_byte()
  buf[10] = (low >> 40).to_byte()
  buf[11] = (low >> 32).to_byte()
  buf[12] = (low >> 24).to_byte()
  buf[13] = (low >> 16).to_byte()
  buf[14] = (low >> 8).to_byte()
  buf[15] = low.to_byte()
  buf.unsafe_reinterpret_as_bytes()
}

///|
#borrow(addr)
extern "c" fn uv_sockaddr_in6_addr(addr : SockaddrIn6) -> In6Addr = "moonbit_uv_sockaddr_in6_addr"

///|
pub fn SockaddrIn6::addr(self : SockaddrIn6) -> In6Addr {
  uv_sockaddr_in6_addr(self)
}

///|
#borrow(src, dst)
extern "c" fn uv_in6_addr_ntop(src : In6Addr, dst : FixedArray[Byte]) -> Int = "moonbit_uv_in6_addr_ntop"

///|
#borrow(src, dst)
extern "c" fn uv_in6_addr_pton(src : Bytes, dst : Ref[In6Addr]) -> Int = "moonbit_uv_in6_addr_pton"

///|
pub fn In6Addr::ntop(self : In6Addr) -> Bytes raise Errno {
  let dst : FixedArray[Byte] = FixedArray::make(_INET6_ADDRSTRLEN, 0)
  let status = uv_in6_addr_ntop(self, dst)
  if status < 0 {
    raise Errno::of_int(status)
  }
  let len = for i in 0..<dst.length() {
    if dst[i] == 0 {
      break i
    }
  } else {
    dst.length()
  }
  let buf : FixedArray[Byte] = FixedArray::make(len, 0)
  buf.unsafe_blit(0, dst, 0, len)
  buf.unsafe_reinterpret_as_bytes()
}

///|
pub fn In6Addr::pton(src : Bytes) -> In6Addr raise Errno {
  let dst = Ref::new(In6Addr(0, 0))
  let status = uv_in6_addr_pton(src, dst)
  if status < 0 {
    raise Errno::of_int(status)
  }
  dst.val
}

///|
struct SockaddrIn6(Bytes)

///|
extern "c" fn uv_sockaddr_in6_make() -> SockaddrIn6 = "moonbit_uv_sockaddr_in6_make"

///|
struct Sockaddr(Bytes)

///|
extern "c" fn uv_sockaddr_make() -> Sockaddr = "moonbit_uv_sockaddr_make"

///|
pub trait ToSockaddr {
  to_sockaddr(self : Self) -> Sockaddr
  ip_name(self : Self) -> Bytes raise Errno
}

///|
pub impl ToSockaddr for Sockaddr with to_sockaddr(self : Sockaddr) -> Sockaddr = "%identity"

///|
pub impl ToSockaddr for SockaddrIn with to_sockaddr(addr : SockaddrIn) -> Sockaddr = "%identity"

///|
pub impl ToSockaddr for SockaddrIn6 with to_sockaddr(addr : SockaddrIn6) -> Sockaddr = "%identity"

///|
enum SockType {
  Stream
  Raw
  Datagram
}

///|
pub fn SockType::stream() -> SockType {
  return Stream
}

///|
pub fn SockType::raw() -> SockType {
  return Raw
}

///|
#deprecated("Use SockType::datagram() instead")
pub fn SockType::dgram() -> SockType {
  return Datagram
}

///|
pub fn SockType::datagram() -> SockType {
  return Datagram
}

///|
extern "c" fn uv_SOCK_STREAM() -> Int = "moonbit_uv_SOCK_STREAM"

///|
let _SOCK_STREAM : Int = uv_SOCK_STREAM()

///|
extern "c" fn uv_SOCK_DGRAM() -> Int = "moonbit_uv_SOCK_DGRAM"

///|
let _SOCK_DGRAM : Int = uv_SOCK_DGRAM()

///|
extern "c" fn uv_SOCK_RAW() -> Int = "moonbit_uv_SOCK_RAW"

///|
let _SOCK_RAW : Int = uv_SOCK_RAW()

///|
fn SockType::of_int(self : Int) -> SockType raise Errno {
  if self == _SOCK_STREAM {
    return Stream
  }
  if self == _SOCK_RAW {
    return Raw
  }
  if self == _SOCK_DGRAM {
    return Datagram
  }
  raise EINVAL
}

///|
fn SockType::to_int(self : SockType) -> Int {
  match self {
    Stream => _SOCK_STREAM
    Raw => _SOCK_RAW
    Datagram => _SOCK_DGRAM
  }
}

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
  type_ : SockType,
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
    flags.0.inner(),
    socks.1,
    flags.1.inner(),
  )
  if status < 0 {
    raise Errno::of_int(status)
  }
  return socks
}
