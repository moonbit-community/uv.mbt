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
/// Condition variable for thread synchronization.
///
/// Condition variables are used in combination with mutexes to allow threads
/// to wait for certain conditions to be met. A thread can wait on a condition
/// variable while holding a mutex, and other threads can signal or broadcast
/// to wake up waiting threads.
///
/// Condition variables must always be used with mutexes. The typical pattern is:
/// 1. Lock the mutex
/// 2. Check the condition in a loop
/// 3. If condition not met, wait on the condition variable
/// 4. When signaled, the loop continues and rechecks the condition
/// 5. Unlock the mutex when done
type Cond

///|
extern "c" fn uv_cond_make() -> Cond = "moonbit_uv_cond_make"

///|
extern "c" fn uv_cond_init(cond : Cond) -> Int = "moonbit_uv_cond_init"

///|
pub fn Cond::new() -> Cond raise Errno {
  let cond = uv_cond_make()
  let status = uv_cond_init(cond)
  if status != 0 {
    raise Errno::of_int(status)
  }
  return cond
}

///|
extern "c" fn uv_cond_copy(cond : Cond, other : Cond) = "moonbit_uv_cond_copy"

///|
extern "c" fn uv_cond_signal(cond : Cond) = "moonbit_uv_cond_signal"

///|
extern "c" fn uv_cond_broadcast(cond : Cond) = "moonbit_uv_cond_broadcast"

///|
extern "c" fn uv_cond_wait(cond : Cond, mutex : Mutex) = "moonbit_uv_cond_wait"

///|
extern "c" fn uv_cond_timedwait(
  cond : Cond,
  mutex : Mutex,
  timeout : UInt64
) -> Int = "moonbit_uv_cond_timedwait"

///|
/// Signal one waiting thread.
///
/// Wake up one thread that is waiting on this condition variable.
/// If no threads are waiting, this call has no effect.
pub fn Cond::signal(self : Cond) -> Unit {
  uv_cond_signal(self)
}

///|
/// Broadcast to all waiting threads.
///
/// Wake up all threads that are waiting on this condition variable.
/// If no threads are waiting, this call has no effect.
pub fn Cond::broadcast(self : Cond) -> Unit {
  uv_cond_broadcast(self)
}

///|
/// Wait on the condition variable.
///
/// The calling thread will block until another thread calls `signal()` or
/// `broadcast()` on this condition variable. The mutex must be locked by
/// the calling thread prior to calling this function. The mutex will be
/// automatically unlocked while waiting and re-locked before returning.
///
/// # Note
/// This function can experience spurious wakeups. Always use this in a loop
/// that checks the actual condition.
pub fn Cond::wait(self : Cond, mutex : Mutex) -> Unit {
  uv_cond_wait(self, mutex)
}

///|
/// Wait on the condition variable with a timeout.
///
/// Similar to `wait()`, but will return after the specified timeout
/// (in nanoseconds) even if no signal was received.
///
/// Returns:
/// - `Ok(())` if signaled before timeout
/// - `Err(ETIMEDOUT)` if timeout occurred
/// - `Err(_)` for other errors
///
/// # Note
/// This function can experience spurious wakeups. Always use this in a loop
/// that checks the actual condition.
pub fn Cond::timedwait(
  self : Cond,
  mutex : Mutex,
  timeout_ns : UInt64
) -> Unit raise Errno {
  let status = uv_cond_timedwait(self, mutex, timeout_ns)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub impl Share for Cond with share(self : Cond) -> Cond {
  let other = uv_cond_make()
  uv_cond_copy(self, other)
  return other
}
