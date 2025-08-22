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
extern "c" fn uv_hrtime() -> UInt64 = "moonbit_uv_hrtime"

///|
/// Returns the current high-resolution timestamp. This is expressed in
/// nanoseconds. It is relative to an arbitrary time in the past. It is not
/// related to the time of day and therefore not subject to clock drift. The
/// primary use is for measuring performance between intervals.
///
/// **Note:** Not every platform can support nanosecond resolution; however,
/// this value will always be in nanoseconds.
pub fn hrtime() -> UInt64 {
  uv_hrtime()
}

///|
extern "c" fn uv_sleep(milliseconds : UInt) = "moonbit_uv_sleep"

///|
pub fn sleep(milliseconds : UInt) -> Unit {
  uv_sleep(milliseconds)
}

///|
#owned(uv)
extern "c" fn uv_now(uv : Loop) -> UInt64 = "moonbit_uv_now"

///|
/// Return the current timestamp in milliseconds. The timestamp is cached at the
/// start of the event loop tick, see `uv_update_time()` for details and
/// rationale.
///
/// The timestamp increases monotonically from some arbitrary point in time.
/// Don't make assumptions about the starting point, you will only get
/// disappointed.
///
/// **Note:** Use `@uv.hrtime()` if you need sub-millisecond granularity.
pub fn Loop::now(self : Loop) -> UInt64 {
  uv_now(self)
}

///|
#owned(uv)
extern "c" fn uv_update_time(uv : Loop) = "moonbit_uv_update_time"

///|
/// Update the event loop's concept of "now". Libuv caches the current time at
/// the start of the event loop tick in order to reduce the number of
/// time-related system calls.
///
/// You won't normally need to call this function unless you have callbacks that
/// block the event loop for longer periods of time, where "longer" is somewhat
/// subjective but probably on the order of a millisecond or more.
pub fn Loop::update_time(self : Loop) -> Unit {
  uv_update_time(self)
}
