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
/// Handle for async watchers in the libuv event loop.
///
/// Async watchers are used to wake up the event loop from another thread.
/// This is useful when you need to notify the main event loop thread
/// of some event from a different thread.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let async_handle = @uv.Async::new(uv, fn(_) {
///   println("Async callback called")
/// })
///
/// // From another thread, you can send a signal:
/// async_handle.send()
///
/// uv.run(Default)
/// async_handle.close(_ => ())
/// uv.close()
/// ```
type Async Bytes

///|
pub impl ToHandle for Async with to_handle(self : Async) -> Handle = "%identity"

///|
pub impl ToHandle for Async with of_handle(handle : Handle) -> Async = "%identity"

///|
extern "c" fn uv_async_make() -> Async = "moonbit_uv_async_make"

///|
extern "c" fn uv_async_init(
  uv : Loop,
  handle : Async,
  cb : (Async) -> Unit
) -> Int = "moonbit_uv_async_init"

///|
pub fn Async::new(self : Loop, cb : (Async) -> Unit) -> Async raise Errno {
  let handle = uv_async_make()
  let status = uv_async_init(self, handle, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return handle
}

///|
extern "c" fn uv_async_send(handle : Async) -> Int = "moonbit_uv_async_send"

///|
pub fn Async::send(self : Async) -> Unit raise Errno {
  let status = uv_async_send(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
