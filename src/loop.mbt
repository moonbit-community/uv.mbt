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
type Loop Bytes

///|
extern "c" fn uv_loop_make() -> Loop = "moonbit_uv_loop_make"

///|
extern "c" fn uv_loop_init(uv : Loop) -> Int = "moonbit_uv_loop_init"

///|
/// Creates a new event loop instance.
///
/// Returns a new event loop that can be used for asynchronous I/O operations.
///
/// Throws an error of type `Errno` if the loop initialization fails due to
/// system resource constraints or other platform-specific issues.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// uv.close()
/// ```
pub fn Loop::new() -> Loop raise Errno {
  let uv = uv_loop_make()
  let status = uv_loop_init(uv)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return uv
}

///|
extern "c" fn uv_loop_close(uv : Loop) -> Int = "moonbit_uv_loop_close"

///|
/// Closes the event loop and releases its associated resources.
///
/// Parameters:
///
/// * `self` : The event loop to close.
///
/// Throws an error of type `Errno` if the loop cannot be closed properly, such
/// as when there are still active handles or requests associated with the loop.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// uv.close()
/// ```
pub fn Loop::close(self : Loop) -> Unit raise Errno {
  let status = uv_loop_close(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub(all) enum RunMode {
  Default = 0
  Once = 1
  NoWait = 2
}

///|
extern "c" fn uv_run(uv : Loop, mode : RunMode) -> Int = "moonbit_uv_run"

///|
/// Runs the event loop with the specified mode.
///
/// Parameters:
///
/// * `self` : The event loop to run.
/// * `mode` : The run mode that determines how the loop executes. Can be
/// `Default` (runs until no more active handles), `Once` (runs once and
/// returns), or `NoWait` (polls for I/O once but doesn't block).
///
/// Throws an error of type `Errno` if the loop fails to run properly.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// uv.run(Default)
/// uv.close()
/// ```
pub fn Loop::run(self : Loop, mode : RunMode) -> Unit raise Errno {
  let status = uv_run(self, mode)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_stop(uv : Loop) = "moonbit_uv_stop"

///|
pub fn Loop::stop(self : Loop) -> Unit {
  uv_stop(self)
}

///|
extern "c" fn uv_walk(uv : Loop, walk_cb : (Handle) -> Unit) = "moonbit_uv_walk"

///|
pub fn Loop::walk(self : Loop, walk_cb : (Handle) -> Unit) -> Unit {
  uv_walk(self, walk_cb)
}

///|
extern "c" fn uv_loop_alive(uv : Loop) -> Int = "moonbit_uv_loop_alive"

///|
pub fn Loop::alive(uv : Loop) -> Bool {
  return uv_loop_alive(uv) != 0
}
