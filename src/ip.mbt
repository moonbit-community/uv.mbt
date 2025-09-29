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
pub suberror InvalidProtocol Int derive(Show, ToJson)

///|
enum Protocol {
  Tcp
  Udp
}

///|
fn Protocol::of_int(value : Int) -> Protocol? {
  match value {
    6 => Some(Tcp)
    17 => Some(Udp)
    _ => None
  }
}

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
/// println(@uv.ip_name(addr))
/// ```
pub fn ip4_addr(ip : Bytes, port : Int) -> SockaddrIn raise Errno {
  let addr = SockaddrIn::default()
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
  let addr = @inet6.Sockaddr::new(@inet6.Addr::new(0, 0, 0, 0, 0, 0, 0, 0), 0)
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
typealias @ip.Protocol

///|
#borrow(src, dst)
extern "c" fn uv_ip_name(src : Sockaddr, dst : Bytes) -> Int = "moonbit_uv_ip_name"
