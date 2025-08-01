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
test "rwlock basic functionality" {
  // Create a new rwlock
  let rwlock = RwLock::new()

  // Test read lock
  rwlock.rdlock()
  rwlock.rdunlock()

  // Test write lock
  rwlock.wrlock()
  rwlock.wrunlock()

  // Test try read lock
  rwlock.tryrdlock()
  rwlock.rdunlock()

  // Test try write lock
  rwlock.trywrlock()
  rwlock.wrunlock()
}

///|
test "rwlock share functionality" {
  let rwlock = RwLock::new()
  let rwlock2 = rwlock.share()

  // Both should work
  rwlock.rdlock()
  rwlock.rdunlock()
  rwlock2.wrlock()
  rwlock2.wrunlock()
}
