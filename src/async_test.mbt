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
test "Async basic functionality" {
  let uv = @uv.Loop::new()
  let mut called = false
  let mut error : Error? = None
  let async_handle = @uv.Async::new(uv, fn(_) { called = true })
  try {
    async_handle.send()
    uv.run(Once)
    async_handle.close(fn(_) {  })
  } catch {
    errno => error = Some(errno)
  }
  uv.close()
  if error is Some(errno) {
    raise errno
  }
  inspect(called, content="true")
}
