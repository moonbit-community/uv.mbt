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
/// Handle for check watchers in the libuv event loop.
///
/// Check watchers run their callbacks once per event loop iteration, right after
/// the event loop has blocked for I/O. They are essentially the counterpart of
/// prepare handles.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let check = @uv.Check::new(uv)
/// let errors = []
/// check.start(fn(_) {
///   println("Check callback running")
///   check.stop() catch {
///     error => errors.push(error)
///   }
///   check.close(() => ())
/// })
/// uv.fs_open(
///   "test/fixtures/example.txt",
///   @uv.OpenFlags::read_only(),
///   0o644,
///   _ => (),
///   error => errors.push(error),
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
/// ```
type Check

///|
pub impl ToHandle for Check with to_handle(check : Check) -> Handle = "%identity"

///|
pub impl ToHandle for Check with of_handle(handle : Handle) -> Check = "%identity"

///|
extern "c" fn uv_check_make() -> Check = "moonbit_uv_check_make"

///|
#owned(uv, check)
extern "c" fn uv_check_init(uv : Loop, check : Check) -> Int = "moonbit_uv_check_init"

///|
pub fn Check::new(self : Loop) -> Check raise Errno {
  let check = uv_check_make()
  let status = uv_check_init(self, check)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return check
}

///|
#owned(check)
extern "c" fn uv_check_start(check : Check, cb : (Check) -> Unit) -> Int = "moonbit_uv_check_start"

///|
#owned(check)
extern "c" fn uv_check_stop(check : Check) -> Int = "moonbit_uv_check_stop"

///|
pub fn Check::start(self : Check, cb : (Check) -> Unit) -> Unit raise Errno {
  let status = uv_check_start(self, fn(check) { cb(check) })
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn Check::stop(self : Check) -> Unit raise Errno {
  let status = uv_check_stop(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
