// Copyright 2026 International Digital Economy Academy
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
test "configure" {
  if @uv.os_uname().sysname() == "Windows_NT" {
    return
  }
  let uv = @uv.Loop::new()
  let signum = @uv.Signum::sigprof()
  uv.configure(@uv.LoopOption::BlockSignal(signum))
  uv.close()
}

///|
test "walk" {
  let uv = @uv.Loop::new()
  let idle = @uv.Idle::new(uv)
  let mut error = None
  fn errno(errno : @uv.Errno) {
    uv.stop()
    error = Some(errno)
  }

  idle.start(fn(_) { idle.stop() catch { error => errno(error) } })
  let mut count = 0
  uv.walk(fn(handle) {
    count += 1
    handle.close(() => ())
  })
  json_inspect(count, content=1)
  uv.run(Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
}

///|
test "backend" {
  if @uv.os_uname().sysname() is "Windows_NT" {
    return
  }
  let uv = @uv.Loop::new()
  ignore(uv.backend_fd())
  ignore(uv.backend_timeout())
  uv.close()
}
