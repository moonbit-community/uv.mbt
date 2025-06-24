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
extern "c" fn uv_tcp_bind(tcp : Tcp, addr : Sockaddr, flags : UInt) -> Int = "moonbit_uv_tcp_bind"

///|
type TcpBindFlags UInt

///|
const TCP_IPV6ONLY : UInt = 1

///|
const TCP_REUSEPORT : UInt = 2

///|
pub fn TcpBindFlags::new(
  ipv6_only~ : Bool = false,
  reuse_port~ : Bool = false
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
pub fn[Sockaddr : ToSockaddr] Tcp::bind(
  self : Tcp,
  addr : Sockaddr,
  flags : TcpBindFlags
) -> Unit raise Errno {
  let status = uv_tcp_bind(self, addr.to_sockaddr(), flags.inner())
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_listen(
  stream : Stream,
  backlog : Int,
  cb : (Stream, Int) -> Unit
) -> Int = "moonbit_uv_listen"

///|
pub fn[Stream : ToStream] listen(
  stream : Stream,
  backlog : Int,
  connection_cb : (Stream) -> Unit,
  error_cb : (Stream, Errno) -> Unit
) -> Unit raise Errno {
  stream.listen(backlog, connection_cb, error_cb)
}

///|
impl ToStream with listen(self, backlog, connection_cb, error_cb) {
  fn uv_cb(self : Stream, status : Int) {
    if status < 0 {
      error_cb(ToStream::of_stream(self), Errno::of_int(status))
    } else {
      connection_cb(ToStream::of_stream(self))
    }
  }

  let status = uv_listen(self.to_stream(), backlog, uv_cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_accept(server : Stream, client : Stream) -> Int = "moonbit_uv_accept"

///|
pub fn[Server : ToStream, Client : ToStream] accept(
  server : Server,
  client : Client
) -> Unit raise Errno {
  let status = uv_accept(server.to_stream(), client.to_stream())
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
type Connect Bytes

///|
pub impl ToReq for Connect with to_req(self : Connect) -> Req = "%identity"

///|
extern "c" fn uv_connect_make() -> Connect = "moonbit_uv_connect_make"

///|
extern "c" fn uv_tcp_connect(
  req : Connect,
  handle : Tcp,
  addr : Sockaddr,
  cb : (Connect, Int) -> Unit
) -> Int = "moonbit_uv_tcp_connect"

///|
pub fn[Sockaddr : ToSockaddr] Tcp::connect(
  self : Tcp,
  addr : Sockaddr,
  connect_cb : (Connect) -> Unit,
  error_cb : (Connect, Errno) -> Unit
) -> Unit raise Errno {
  fn cb(req : Connect, status : Int) {
    if status < 0 {
      error_cb(req, Errno::of_int(status))
    } else {
      connect_cb(req)
    }
  }

  let req = uv_connect_make()
  let status = uv_tcp_connect(req, self, addr.to_sockaddr(), cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
