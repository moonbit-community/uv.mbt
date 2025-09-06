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
pub fn[IpName : IpName] ip_name(sockaddr : IpName) -> Bytes raise Errno {
  sockaddr.ip_name()
}

///|
pub trait IpName {
  ip_name(self : Self) -> Bytes raise Errno
}

///|
pub impl IpName for @socket.Sockaddr with ip_name(self : @socket.Sockaddr) -> Bytes raise Errno {
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
extern "c" fn uv_ip4_addr(ip : Bytes, port : Int, addr : @inet.Sockaddr) -> Int = "moonbit_uv_ip4_addr"

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
pub fn ip4_addr(ip : Bytes, port : Int) -> @inet.Sockaddr raise Errno {
  let addr = @inet.Sockaddr::new(
    @inet.Addr::new(0, 0, 0, 0),
    @inet.Port::new(0),
  )
  let status = uv_ip4_addr(ip, port, addr)
  if status < 0 {
    raise Errno::of_int(status)
  }
  addr
}

///|
#borrow(addr, dst)
extern "c" fn uv_ip4_name(addr : @inet.Sockaddr, dst : Bytes) -> Int = "moonbit_uv_ip4_name"

///|
pub impl IpName for @inet.Sockaddr with ip_name(self : @inet.Sockaddr) -> Bytes raise Errno {
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
extern "c" fn uv_ip6_addr(
  ip : Bytes,
  port : Int,
  addr : @inet6.Sockaddr,
) -> Int = "moonbit_uv_ip6_addr"

///|
pub fn ip6_addr(ip : Bytes, port : Int) -> @inet6.Sockaddr raise Errno {
  let addr = @inet6.Sockaddr::new(
    @inet6.Addr::new(0, 0, 0, 0, 0, 0, 0, 0),
    @inet6.Port::new(0),
  )
  let status = uv_ip6_addr(ip, port, addr)
  if status < 0 {
    raise Errno::of_int(status)
  }
  addr
}

///|
#borrow(addr, dst)
extern "c" fn uv_ip6_name(addr : @inet6.Sockaddr, dst : Bytes) -> Int = "moonbit_uv_ip6_name"

///|
pub impl IpName for @inet6.Sockaddr with ip_name(self : @inet6.Sockaddr) -> Bytes raise Errno {
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
#borrow(src, dst)
extern "c" fn uv_ip_name(src : @socket.Sockaddr, dst : Bytes) -> Int = "moonbit_uv_ip_name"
