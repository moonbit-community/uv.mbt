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
test "Poll::file" {
  let uv = @uv.Loop::new()
  let errors = []
  let socks = @uv.socketpair(
    @uv.SockType::stream(),
    (PipeFlags::new(), PipeFlags::new()),
  )
  let poll = @uv.Poll::socket(uv, socks.0)
  let writer = @uv.Tcp::new(uv)
  writer.open(socks.1)
  let data : Bytes = "hello"
  let mut readable = false
  poll.start(
    PollEvent::readable(),
    (_, events) => {
      if events.is_readable() {
        readable = true
      }
      poll.stop() catch {
        e => errors.push(e)
      }
      poll.close(() => ())
    },
    (_, e) => errors.push(e),
  )
  let timer = @uv.Timer::new(uv)
  timer.start(timeout=100, repeat=0, _ => {
    try
      writer.write([data], () => writer.close(() => ()), errors.push(_))
      |> ignore()
    catch {
      e => errors.push(e)
    }
    timer.stop() catch {
      e => errors.push(e)
    }
    timer.close(() => ())
  })
  uv.run(Default)
  for e in errors {
    raise e
  }
  assert_true(readable)
  uv.close()
}
