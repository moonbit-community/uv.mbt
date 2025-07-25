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
