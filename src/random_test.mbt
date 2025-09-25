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
test "random" {
  let uv = @uv.Loop::new()
  let buffer = Bytes::make(16, 0)
  let mut result = None
  let mut error = None
  uv.random(buffer[:], 0, fn(bytes) { result = Some(bytes) }, fn(errno) {
    error = Some(errno)
  })
  |> ignore()
  uv.run(Default)
  uv.stop()
  uv.close()
  assert_true(result is Some(result) && result.length() == buffer.length())
  if error is Some(errno) {
    raise errno
  }
}

///|
test "random_sync" {
  let uv = @uv.Loop::new()
  let buffer = Bytes::make(16, 0)
  let original_buffer = buffer.copy()
  
  // Perform synchronous random generation
  uv.random_sync(buffer[:], 0)
  
  // Verify that the buffer was modified (contains random data)
  assert_true(buffer != original_buffer)
  
  // Verify the buffer size remains the same
  assert_true(buffer.length() == 16)
  
  uv.close()
}
