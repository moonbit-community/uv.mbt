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
test "socketpair" {
  let uv = @uv.Loop::new()
  let errors = []
  let socks = @uv.socketpair(
    @uv.SockType::stream(),
    (PipeFlags::new(), PipeFlags::new()),
  )
  let reader = @uv.Tcp::new(uv)
  reader.open(socks.0)
  let writer = @uv.Tcp::new(uv)
  writer.open(socks.1)
  let data : Bytes = "hello"
  reader.read_start(
    (_, _) => Bytes::make(32, 0)[:],
    (_, count, bytes) => {
      assert_eq(bytes[:count], data) catch {
        e => errors.push(e)
      }
      reader.read_stop() catch {
        e => errors.push(e)
      }
      reader.close(() => ())
    },
    (_, e) => errors.push(e),
  )
  writer.write([data], () => writer.close(() => ()), e => errors.push(e))
  |> ignore()
  uv.run(Default)
  uv.close()
}

///|
test "ntop-pton" {
  let in_addr : @uv.InAddr = @uv.InAddr::pton("127.0.0.1")
  @json.inspect(in_addr.ntop(), content="127.0.0.1")
  let in6_addr : @uv.In6Addr = @uv.In6Addr::pton("::1")
  @json.inspect(in6_addr.ntop(), content="::1")
}

///|
test "addr" {
  let sockaddr_in : @uv.SockaddrIn = @uv.ip4_addr("127.0.0.1", 8080)
  @json.inspect(sockaddr_in.addr().ntop(), content="127.0.0.1")
}

///|
test "port" {
  let sockaddr_in : @uv.SockaddrIn = @uv.ip4_addr("127.0.0.1", 8080)
  @json.inspect(sockaddr_in.port(), content=8080)
  let sockaddr_in6 : @uv.SockaddrIn6 = @uv.ip6_addr("::1", 8080)
  @json.inspect(sockaddr_in6.port(), content=8080)
}

///|
test "InAddr" {
  let in_addr : @uv.InAddr = @uv.InAddr::new(1, 2, 3, 4)
  @json.inspect(in_addr.ntop(), content="1.2.3.4")
  @json.inspect(in_addr.to_bytes().to_array(), content=[1, 2, 3, 4])
}

///|
test "In6Addr" {
  let in6_addr : @uv.In6Addr = @uv.In6Addr::new(
    0x2001, 0x0db8, 0x85a3, 0x0000, 0x0000, 0x8a2e, 0x0370, 0x7334,
  )
  @json.inspect(in6_addr.ntop(), content="2001:db8:85a3::8a2e:370:7334")
  @json.inspect(in6_addr.to_bytes().to_array(), content=[
    0x20, 0x01, 0x0d, 0xb8, 0x85, 0xa3, 0x00, 0x00, 0x00, 0x00, 0x8a, 0x2e, 0x03,
    0x70, 0x73, 0x34,
  ])
}
