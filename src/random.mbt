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
type Random

///|
extern "c" fn uv_random_make() -> Random = "moonbit_uv_random_make"

///|
extern "c" fn uv_random(
  uv : Loop,
  req : Random,
  buffer : Bytes,
  buffer_offset : Int,
  buffer_length : Int,
  flags : Int,
  random_cb : (Random, Int, Bytes, Int, Int) -> Unit
) -> Int = "moonbit_uv_random"

///|
pub fn Loop::random(
  self : Loop,
  buffer : @bytes.View,
  flags : Int,
  random_cb : (Random, @bytes.View) -> Unit,
  error_cb : (Random, Errno) -> Unit
) -> Unit raise Errno {
  fn uv_random_cb(random, status, buffer : Bytes, offset, length) {
    if status < 0 {
      error_cb(random, Errno::of_int(status))
    } else {
      random_cb(random, buffer[offset:offset + length])
    }
  }

  let req = uv_random_make()
  let buffer_offset = buffer.start_offset()
  let buffer_length = buffer.length()
  let buffer = buffer.data()
  let status = uv_random(
    self, req, buffer, buffer_offset, buffer_length, flags, uv_random_cb,
  )
  if status < 0 {
    raise Errno::of_int(status)
  }
}
