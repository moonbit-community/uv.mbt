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
test "native_thread_test" {
  let buffer = []
  let thread = Thread::new(() => buffer.push("thread!"))
  buffer.push("main")
  thread.join()
  buffer.push("joined")
  @json.inspect(buffer.last(), content=["joined"])
  assert_true(Thread::self() == Thread::self())
  let current = Thread::self()
  let mut error = None
  let thread = Thread::new(fn() {
    assert_false(Thread::self() == current) catch {
      e => error = Some(e)
    }
  })
  thread.join()
  if error is Some(e) {
    raise e
  }
}
