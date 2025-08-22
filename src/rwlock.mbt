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
type RwLock

///|
#deprecated
pub typealias RwLock as RWLock

///|
extern "c" fn uv_rwlock_make() -> RwLock = "moonbit_uv_rwlock_make"

///|
#owned(rwlock)
extern "c" fn uv_rwlock_init(rwlock : RwLock) -> Int = "moonbit_uv_rwlock_init"

///|
pub fn RwLock::new() -> RwLock raise Errno {
  let rwlock = uv_rwlock_make()
  let status = uv_rwlock_init(rwlock)
  if status != 0 {
    raise Errno::of_int(status)
  }
  return rwlock
}

///|
#owned(rwlock, other)
extern "c" fn uv_rwlock_copy(rwlock : RwLock, other : RwLock) = "moonbit_uv_rwlock_copy"

///|
#owned(rwlock)
extern "c" fn uv_rwlock_rdlock(rwlock : RwLock) = "moonbit_uv_rwlock_rdlock"

///|
#owned(rwlock)
extern "c" fn uv_rwlock_tryrdlock(rwlock : RwLock) -> Int = "moonbit_uv_rwlock_tryrdlock"

///|
#owned(rwlock)
extern "c" fn uv_rwlock_rdunlock(rwlock : RwLock) = "moonbit_uv_rwlock_rdunlock"

///|
#owned(rwlock)
extern "c" fn uv_rwlock_wrlock(rwlock : RwLock) = "moonbit_uv_rwlock_wrlock"

///|
#owned(rwlock)
extern "c" fn uv_rwlock_trywrlock(rwlock : RwLock) -> Int = "moonbit_uv_rwlock_trywrlock"

///|
#owned(rwlock)
extern "c" fn uv_rwlock_wrunlock(rwlock : RwLock) = "moonbit_uv_rwlock_wrunlock"

///|
pub fn RwLock::rdlock(self : RwLock) -> Unit {
  uv_rwlock_rdlock(self)
}

///|
pub fn RwLock::tryrdlock(self : RwLock) -> Unit raise Errno {
  let status = uv_rwlock_tryrdlock(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn RwLock::rdunlock(self : RwLock) -> Unit {
  uv_rwlock_rdunlock(self)
}

///|
pub fn RwLock::wrlock(self : RwLock) -> Unit {
  uv_rwlock_wrlock(self)
}

///|
pub fn RwLock::trywrlock(self : RwLock) -> Unit raise Errno {
  let status = uv_rwlock_trywrlock(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn RwLock::wrunlock(self : RwLock) -> Unit {
  uv_rwlock_wrunlock(self)
}

///|
pub impl Share for RwLock with share(self : RwLock) -> RwLock {
  let other = uv_rwlock_make()
  uv_rwlock_copy(self, other)
  return other
}
