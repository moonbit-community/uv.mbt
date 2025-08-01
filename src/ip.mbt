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
pub impl ToSockaddr for Sockaddr with ip_name(self : Sockaddr) -> Bytes raise Errno {
  let self = self.to_sockaddr()
  let bytes = Bytes::make(_IF_NAMESIZE, 0)
  let status = uv_ip_name(self, bytes)
  if status < 0 {
    raise Errno::of_int(status)
  }
  let buffer = @buffer.new()
  for i = 0; bytes[i] != 0; i = i + 1 {
    buffer.write_byte(bytes[i])
  }
  buffer.contents()
}

///|
#borrow(ip, addr)
extern "c" fn uv_ip4_addr(ip : Bytes, port : Int, addr : SockaddrIn) -> Int = "moonbit_uv_ip4_addr"

///|
/// Creates an IPv4 socket address structure from an IP address and port number.
///
/// Parameters:
///
/// * `ip` : The IPv4 address as a null-terminated byte string (e.g.,
/// "127.0.0.1").
/// * `port` : The port number for the socket address.
///
/// Returns a `SockaddrIn` structure representing the IPv4 socket address that
/// can be used with TCP operations like binding or connecting.
///
/// Example:
///
/// ```moonbit
/// let addr = @uv.ip4_addr("127.0.0.1", 8080)
/// println(addr.ip_name())
/// ```
pub fn ip4_addr(ip : Bytes, port : Int) -> SockaddrIn raise Errno {
  let addr = uv_sockaddr_in_make()
  let status = uv_ip4_addr(ip, port, addr)
  if status < 0 {
    raise Errno::of_int(status)
  }
  addr
}

///|
#borrow(addr, dst)
extern "c" fn uv_ip4_name(addr : SockaddrIn, dst : Bytes) -> Int = "moonbit_uv_ip4_name"

///|
pub impl ToSockaddr for SockaddrIn with ip_name(self : SockaddrIn) -> Bytes raise Errno {
  let bytes = Bytes::make(_IF_NAMESIZE, 0)
  let status = uv_ip4_name(self, bytes)
  if status < 0 {
    raise Errno::of_int(status)
  }
  let buffer = @buffer.new()
  for i = 0; bytes[i] != 0; i = i + 1 {
    buffer.write_byte(bytes[i])
  }
  buffer.contents()
}

///|
#borrow(ip, addr)
extern "c" fn uv_ip6_addr(ip : Bytes, port : Int, addr : SockaddrIn6) -> Int = "moonbit_uv_ip6_addr"

///|
pub fn ip6_addr(ip : Bytes, port : Int) -> SockaddrIn6 raise Errno {
  let addr = uv_sockaddr_in6_make()
  let status = uv_ip6_addr(ip, port, addr)
  if status < 0 {
    raise Errno::of_int(status)
  }
  addr
}

///|
#borrow(addr, dst)
extern "c" fn uv_ip6_name(addr : SockaddrIn6, dst : Bytes) -> Int = "moonbit_uv_ip6_name"

///|
pub impl ToSockaddr for SockaddrIn6 with ip_name(self : SockaddrIn6) -> Bytes raise Errno {
  let bytes = Bytes::make(_IF_NAMESIZE, 0)
  let status = uv_ip6_name(self, bytes)
  if status < 0 {
    raise Errno::of_int(status)
  }
  let buffer = @buffer.new()
  for i = 0; bytes[i] != 0; i = i + 1 {
    buffer.write_byte(bytes[i])
  }
  buffer.contents()
}

///|
pub enum Protocol {
  Tcp
  Udp
} derive(Show)

///|
pub fn Protocol::tcp() -> Protocol {
  return Tcp
}

///|
pub fn Protocol::udp() -> Protocol {
  return Udp
}

///|
extern "c" fn uv_IPPROTO_UDP() -> Int = "moonbit_uv_IPPROTO_UDP"

///|
let _IPPROTO_UDP : Int = uv_IPPROTO_UDP()

///|
extern "c" fn uv_IPPROTO_TCP() -> Int = "moonbit_uv_IPPROTO_TCP"

///|
let _IPPROTO_TCP : Int = uv_IPPROTO_TCP()

///|
extern "c" fn uv_IPPROTO_IP() -> Int = "moonbit_uv_IPPROTO_IP"

///|
let _IPPROTO_IP : Int = uv_IPPROTO_IP()

///|
fn Protocol::of_int(self : Int) -> Protocol raise Errno {
  if self == _IPPROTO_TCP {
    return Tcp
  }
  if self == _IPPROTO_UDP {
    return Udp
  }
  raise EINVAL
}

///|
fn Protocol::to_int(self : Protocol) -> Int {
  match self {
    Tcp => _IPPROTO_TCP
    Udp => _IPPROTO_UDP
  }
}

///|
#borrow(src, dst)
extern "c" fn uv_ip_name(src : Sockaddr, dst : Bytes) -> Int = "moonbit_uv_ip_name"
