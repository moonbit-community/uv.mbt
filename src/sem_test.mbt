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
test "sem new and basic operations" {
  let sem = Sem::new(1U)

  // Test wait on available semaphore
  sem.wait()

  // Test trywait on empty semaphore
  try {
    sem.trywait()
    fail("trywait should have failed")
  } catch {
    _ => ()
  }

  // Test post to signal semaphore
  sem.post()

  // Test trywait on available semaphore
  sem.trywait() catch {
    errno => fail("trywait should have succeeded: \{errno}")
  }
}

///|
test "sem with initial value 0" {
  let sem = Sem::new(0U)

  // Test trywait on empty semaphore
  try {
    sem.trywait()
    fail("trywait should have failed")
  } catch {
    _ => ()
  }

  // Post to signal semaphore
  sem.post()

  // Now wait should succeed
  sem.wait()
}

///|
test "sem with initial value > 1" {
  let sem = Sem::new(3U)

  // Test multiple waits
  sem.wait()
  sem.wait()
  sem.wait()

  // Fourth wait should block, so we use trywait which should fail
  try {
    sem.trywait()
    fail("trywait should have failed")
  } catch {
    _ => ()
  }

  // Post some signals
  sem.post()
  sem.post()

  // Now we should be able to wait twice
  try {
    sem.trywait()
    sem.trywait()
  } catch {
    errno => fail("trywait should have succeeded: \{errno}")
  }
}

///|
test "sem share functionality" {
  let sem1 = Sem::new(1U)
  let sem2 = sem1.share()

  // Wait on the first semaphore
  sem1.wait()

  // Try to wait on the shared semaphore (should fail since they share the same underlying semaphore)
  try {
    sem2.trywait()
    fail("trywait should have failed on shared semaphore")
  } catch {
    _errno => ()
  }

  // Post to the shared semaphore
  sem2.post()

  // Now the original semaphore should be available
  sem1.trywait() catch {
    errno =>
      fail("trywait should have succeeded on original semaphore: \{errno}")
  }
}
