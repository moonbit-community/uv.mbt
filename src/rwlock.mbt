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
type RWLock

///|
extern "c" fn uv_rwlock_make() -> RWLock = "moonbit_uv_rwlock_make"

///|
extern "c" fn uv_rwlock_init(rwlock : RWLock) -> Int = "moonbit_uv_rwlock_init"

///|
pub fn RWLock::new() -> RWLock raise Errno {
  let rwlock = uv_rwlock_make()
  let status = uv_rwlock_init(rwlock)
  if status != 0 {
    raise Errno::of_int(status)
  }
  return rwlock
}

///|
extern "c" fn uv_rwlock_copy(rwlock : RWLock, other : RWLock) = "moonbit_uv_rwlock_copy"

///|
extern "c" fn uv_rwlock_rdlock(rwlock : RWLock) = "moonbit_uv_rwlock_rdlock"

///|
extern "c" fn uv_rwlock_tryrdlock(rwlock : RWLock) -> Int = "moonbit_uv_rwlock_tryrdlock"

///|
extern "c" fn uv_rwlock_rdunlock(rwlock : RWLock) = "moonbit_uv_rwlock_rdunlock"

///|
extern "c" fn uv_rwlock_wrlock(rwlock : RWLock) = "moonbit_uv_rwlock_wrlock"

///|
extern "c" fn uv_rwlock_trywrlock(rwlock : RWLock) -> Int = "moonbit_uv_rwlock_trywrlock"

///|
extern "c" fn uv_rwlock_wrunlock(rwlock : RWLock) = "moonbit_uv_rwlock_wrunlock"

///|
pub fn RWLock::rdlock(self : RWLock) -> Unit {
  uv_rwlock_rdlock(self)
}

///|
pub fn RWLock::tryrdlock(self : RWLock) -> Unit raise Errno {
  let status = uv_rwlock_tryrdlock(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn RWLock::rdunlock(self : RWLock) -> Unit {
  uv_rwlock_rdunlock(self)
}

///|
pub fn RWLock::wrlock(self : RWLock) -> Unit {
  uv_rwlock_wrlock(self)
}

///|
pub fn RWLock::trywrlock(self : RWLock) -> Unit raise Errno {
  let status = uv_rwlock_trywrlock(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn RWLock::wrunlock(self : RWLock) -> Unit {
  uv_rwlock_wrunlock(self)
}

///|
pub impl Share for RWLock with share(self : RWLock) -> RWLock {
  let other = uv_rwlock_make()
  uv_rwlock_copy(self, other)
  return other
}
