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
struct Loop(Bytes)

///|
extern "c" fn uv_loop_make() -> Loop = "moonbit_uv_loop_make"

///|
#owned(uv)
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
pub(all) enum LoopOption {
  BlockSignal(Signum)
  MeasureIdleTime
  UseIoUringSqPoll
}

///|
#owned(uv)
extern "c" fn uv_loop_configure_block_signal(uv : Loop, signum : Signum) -> Int = "moonbit_uv_loop_configure_block_signal"

///|
#owned(uv)
extern "c" fn uv_loop_configure(uv : Loop, option : Int) -> Int = "moonbit_uv_loop_configure"

///|
pub fn Loop::configure(self : Loop, option : LoopOption) -> Unit raise Errno {
  let status = match option {
    LoopOption::BlockSignal(signum) =>
      uv_loop_configure_block_signal(self, signum)
    LoopOption::MeasureIdleTime => uv_loop_configure(self, 1)
    LoopOption::UseIoUringSqPoll => uv_loop_configure(self, 2)
  }
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(uv)
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
#owned(uv)
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
#owned(uv)
extern "c" fn uv_stop(uv : Loop) = "moonbit_uv_stop"

///|
pub fn Loop::stop(self : Loop) -> Unit {
  uv_stop(self)
}

///|
#owned(uv)
extern "c" fn uv_walk(uv : Loop, walk_cb : (Handle) -> Unit) = "moonbit_uv_walk"

///|
pub fn Loop::walk(self : Loop, walk_cb : (Handle) -> Unit) -> Unit {
  uv_walk(self, walk_cb)
}

///|
#owned(uv)
extern "c" fn uv_loop_alive(uv : Loop) -> Int = "moonbit_uv_loop_alive"

///|
pub fn Loop::alive(uv : Loop) -> Bool {
  return uv_loop_alive(uv) != 0
}

///|
#owned(uv)
extern "c" fn uv_loop_fork(uv : Loop) -> Int = "moonbit_uv_loop_fork"

///|
pub fn Loop::fork(uv : Loop) -> Unit raise Errno {
  let status = uv_loop_fork(uv)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(uv)
extern "c" fn uv_backend_fd(uv : Loop) -> Int = "moonbit_uv_backend_fd"

///|
pub fn Loop::backend_fd(uv : Loop) -> Int raise Errno {
  let status = uv_backend_fd(uv)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return status
}

///|
#owned(uv)
extern "c" fn uv_backend_timeout(uv : Loop) -> Int = "moonbit_uv_backend_timeout"

///|
pub fn Loop::backend_timeout(uv : Loop) -> Int raise Errno {
  let status = uv_backend_timeout(uv)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return status
}
