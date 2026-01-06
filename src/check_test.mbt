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
test "Check" {
  let uv = @uv.Loop::new()
  let check = @uv.Check::new(uv)
  let errors = []
  let mut check_called = false
  check.start(fn(_) {
    check_called = true
    check.stop() catch {
      error => errors.push(error)
    }
    check.close(() => ())
  })
  uv.fs_open(
    "test/fixtures/example.txt",
    @uv.OpenFlags::read_only(),
    0o644,
    _ => (),
    e => errors.push(e),
  )
  |> ignore()
  uv.run(Default)
  uv.close()
  for error in errors {
    raise error
  }
  @json.inspect(check_called, content=true)
}
