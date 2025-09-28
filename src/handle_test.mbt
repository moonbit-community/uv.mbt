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
test "send_buffer_size" {
  let uv = @uv.Loop::new()
  let server = @uv.Tcp::new(uv)
  let addr = @uv.ip4_addr("127.0.0.1", 8544)
  server.bind(addr, @uv.TcpBindFlags::new())
  let old_send_buffer_size = server.get_send_buffer_size()
  let new_send_buffer_size = old_send_buffer_size + 1024
  server.set_send_buffer_size(new_send_buffer_size)
  @json.inspect(
    server.get_send_buffer_size() >= new_send_buffer_size,
    content=true,
  )
  server.close(() => ())
  uv.run(Default)
  uv.close()
}

///|
test "recv_buffer_size" {
  let uv = @uv.Loop::new()
  let server = @uv.Tcp::new(uv)
  let addr = @uv.ip4_addr("127.0.0.1", 8544)
  server.bind(addr, @uv.TcpBindFlags::new())
  let old_recv_buffer_size = server.get_recv_buffer_size()
  let new_recv_buffer_size = old_recv_buffer_size + 1024
  server.set_recv_buffer_size(new_recv_buffer_size)
  @json.inspect(
    server.get_recv_buffer_size() >= new_recv_buffer_size,
    content=true,
  )
  server.close(() => ())
  uv.run(Default)
  uv.close()
}
