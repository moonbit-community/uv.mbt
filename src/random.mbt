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
pub impl ToReq for Random with to_req(self : Random) -> Req = "%identity"

///|
extern "c" fn uv_random_make() -> Random = "moonbit_uv_random_make"

///|
#owned(uv, req, buffer)
extern "c" fn uv_random(
  uv : Loop,
  req : Random,
  buffer : Bytes,
  buffer_offset : Int,
  buffer_length : Int,
  flags : Int,
  random_cb : (Random, Int, Bytes, Int, Int) -> Unit,
) -> Int = "moonbit_uv_random"

///|
#as_free_fn
pub fn Loop::random(
  self : Loop,
  buffer : @bytes.View,
  flags : Int,
  random_cb : (@bytes.View) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Random raise Errno {
  fn uv_random_cb(_, status, buffer : Bytes, offset, length) {
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      random_cb(buffer[offset:offset + length])
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
  return req
}

///|
#owned(uv, req, buffer)
extern "c" fn uv_random_sync(
  uv : Loop,
  req : Random,
  buffer : Bytes,
  buffer_offset : Int,
  buffer_length : Int,
  flags : Int,
) -> Int = "moonbit_uv_random_sync"

///|
/// Synchronously generates random data.
///
/// The synchronous version may block indefinitely when not enough entropy is
/// available. This function blocks the current thread until the random data
/// generation completes. Unlike the asynchronous `random` function, this 
/// operation does not require callbacks and returns immediately upon successful 
/// completion or failure.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `buffer` : A view of the buffer to fill with random data.
/// * `flags` : Flags to control the random data generation (typically 0).
///
/// Throws an error of type `Errno` if random data cannot be generated (e.g.,
/// insufficient entropy or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let buffer = Bytes::make(16, 0)
/// uv.random_sync(buffer[:], 0)
/// // buffer now contains random data
/// uv.close()
/// ```
#as_free_fn
pub fn Loop::random_sync(
  self : Loop,
  buffer : @bytes.View,
  flags : Int,
) -> Unit raise Errno {
  let req = uv_random_make()
  let buffer_offset = buffer.start_offset()
  let buffer_length = buffer.length()
  let buffer_data = buffer.data()
  let status = uv_random_sync(
    self, req, buffer_data, buffer_offset, buffer_length, flags,
  )
  if status < 0 {
    raise Errno::of_int(status)
  }
}
