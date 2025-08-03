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
} derive(Show)

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
