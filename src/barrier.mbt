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
type Barrier

///|
extern "c" fn uv_barrier_make() -> Barrier = "moonbit_uv_barrier_make"

///|
#owned(barrier)
extern "c" fn uv_barrier_init(barrier : Barrier, count : UInt) -> Int = "moonbit_uv_barrier_init"

///|
pub fn Barrier::new(count : UInt) -> Barrier raise Errno {
  let barrier = uv_barrier_make()
  let status = uv_barrier_init(barrier, count)
  if status != 0 {
    raise Errno::of_int(status)
  }
  return barrier
}

///|
#owned(barrier)
extern "c" fn uv_barrier_wait(barrier : Barrier) -> Int = "moonbit_uv_barrier_wait"

///|
pub fn Barrier::wait(self : Barrier) -> Bool raise Errno {
  let status = uv_barrier_wait(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
  // Returns true if this thread is the last to arrive at the barrier
  return status > 0
}