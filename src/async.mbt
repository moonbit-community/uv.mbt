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
/// Wake up the event loop and call the async handle’s callback.
///
/// RETURNS:
///   0 on success, or an error code < 0 on failure.
///
/// Note: It’s safe to call this function from any thread. The callback will
/// be called on the loop thread.
///
/// Note: `uv_async_send()` is
/// [async-signal-safe](https://man7.org/linux/man-pages/man7/signal-safety.7.html).
/// It’s safe to call this function from a signal handler.
///
/// Warning: libuv will coalesce calls to `uv_async_send()`, that is, not every
/// call to it will yield an execution of the callback. For example: if
/// `uv_async_send()` is called 5 times in a row before the callback is called,
/// the callback will only be called once. If `uv_async_send()` is called again
/// after the callback was called, it will be called again.
type Async

///|
pub impl ToHandle for Async with to_handle(handle : Async) -> Handle = "%identity"

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
/// Create a new async handle.
///
/// @param cb The callback to execute when the async handle is triggered
/// @return A new Async handle
/// @raise Errno if the async handle could not be created
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
/// Wake up the event loop and call the async handle's callback.
///
/// This function is async-signal-safe and can be called from any thread.
/// Multiple calls to send() may result in only one callback execution due to coalescing.
/// The callback is guaranteed to be called at least once after send() is called.
///
/// @return Unit
/// @raise Errno if the send operation failed
pub fn Async::send(self : Async) -> Unit raise Errno {
  let status = uv_async_send(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
