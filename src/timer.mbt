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
type Timer

///|
pub impl ToHandle for Timer with to_handle(self : Timer) -> Handle = "%identity"

///|
pub impl ToHandle for Timer with of_handle(self : Handle) -> Timer = "%identity"

///|
extern "c" fn uv_timer_make() -> Timer = "moonbit_uv_timer_make"

///|
#owned(uv, timer)
extern "c" fn uv_timer_init(uv : Loop, timer : Timer) -> Int = "moonbit_uv_timer_init"

///|
pub fn Timer::new(self : Loop) -> Timer raise Errno {
  let timer = uv_timer_make()
  let status = uv_timer_init(self, timer)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return timer
}

///|
#owned(timer)
extern "c" fn uv_timer_start(
  timer : Timer,
  cb : (Timer) -> Unit,
  // We shall never use Int/UInt for time, even in MoonBit.
  timeout : UInt64,
  repeat : UInt64,
) -> Int = "moonbit_uv_timer_start"

///|
pub fn Timer::start(
  self : Timer,
  timeout~ : UInt64,
  repeat~ : UInt64,
  cb : (Timer) -> Unit,
) -> Unit raise Errno {
  let status = uv_timer_start(self, cb, timeout, repeat)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(timer)
extern "c" fn uv_timer_stop(timer : Timer) -> Int = "moonbit_uv_timer_stop"

///|
pub fn Timer::stop(self : Timer) -> Unit raise Errno {
  let status = uv_timer_stop(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(timer)
extern "c" fn uv_timer_set_repeat(timer : Timer, repeat : UInt64) = "moonbit_uv_timer_set_repeat"

///|
pub fn Timer::set_repeat(self : Timer, repeat : UInt64) -> Unit {
  uv_timer_set_repeat(self, repeat)
}

///|
#owned(timer)
extern "c" fn uv_timer_get_repeat(timer : Timer) -> UInt64 = "moonbit_uv_timer_get_repeat"

///|
pub fn Timer::get_repeat(self : Timer) -> UInt64 {
  uv_timer_get_repeat(self)
}

///|
#owned(timer)
extern "c" fn uv_timer_get_due_in(timer : Timer) -> UInt64 = "moonbit_uv_timer_get_due_in"

///|
pub fn Timer::get_due_in(self : Timer) -> UInt64 {
  uv_timer_get_due_in(self)
}
