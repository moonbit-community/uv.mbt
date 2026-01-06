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
test "cond new" {
  let _cond = Cond::new()
  inspect("cond created successfully", content="cond created successfully")
}

///|
test "cond signal and broadcast" {
  let cond = Cond::new()
  // These operations should work without error on a new condition variable
  cond.signal()
  cond.broadcast()
  inspect(
    "signal and broadcast completed",
    content="signal and broadcast completed",
  )
}

///|
test "cond share" {
  let cond = Cond::new()
  let shared_cond = cond.share()
  // Both should be valid condition variables
  cond.signal()
  shared_cond.broadcast()
  inspect("sharing works correctly", content="sharing works correctly")
}

///|
test "cond timedwait timeout" {
  let mutex = Mutex::new()
  let cond = Cond::new()
  mutex.lock()

  // Test timeout (1 millisecond = 1,000,000 nanoseconds)
  let timeout_ns : UInt64 = 1000000UL // 1ms
  try {
    cond.timedwait(mutex, timeout_ns)
    fail("Should have timed out")
  } catch {
    Errno::ETIMEDOUT => ()
    e => fail("Unexpected error: \{e}")
  }
  mutex.unlock()
}
