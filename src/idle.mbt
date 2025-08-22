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
/// Handle for idle watchers in the libuv event loop.
///
/// Idle watchers run their callbacks once per event loop iteration, right before
/// the event loop blocks for I/O. They are useful for performing background
/// tasks when the event loop is idle.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let errors = []
/// let idle = @uv.Idle::new(uv)
/// idle.start(fn(_) {
///   println("Idle callback running")
///   idle.stop() catch {
///     error => errors.push(error)
///   }
///   idle.close(() => ())
/// })
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
/// ```
type Idle

///|
pub impl ToHandle for Idle with to_handle(idle : Idle) -> Handle = "%identity"

///|
pub impl ToHandle for Idle with of_handle(handle : Handle) -> Idle = "%identity"

///|
extern "c" fn uv_idle_make() -> Idle = "moonbit_uv_idle_make"

///|
#owned(uv, idle)
extern "c" fn uv_idle_init(uv : Loop, idle : Idle) -> Int = "moonbit_uv_idle_init"

///|
pub fn Idle::new(self : Loop) -> Idle raise Errno {
  let idle = uv_idle_make()
  let status = uv_idle_init(self, idle)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return idle
}

///|
#owned(idle)
extern "c" fn uv_idle_start(idle : Idle, cb : (Idle) -> Unit) -> Int = "moonbit_uv_idle_start"

///|
#owned(idle)
extern "c" fn uv_idle_stop(idle : Idle) -> Int = "moonbit_uv_idle_stop"

///|
pub fn Idle::start(self : Idle, cb : (Idle) -> Unit) -> Unit raise Errno {
  let status = uv_idle_start(self, fn(idle) { cb(idle) })
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn Idle::stop(self : Idle) -> Unit raise Errno {
  let status = uv_idle_stop(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
