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
type Sem

///|
extern "c" fn uv_sem_make() -> Sem = "moonbit_uv_sem_make"

///|
extern "c" fn uv_sem_init(sem : Sem, value : UInt) -> Int = "moonbit_uv_sem_init"

///|
pub fn Sem::new(value : UInt) -> Sem raise Errno {
  let sem = uv_sem_make()
  let status = uv_sem_init(sem, value)
  if status != 0 {
    raise Errno::of_int(status)
  }
  return sem
}

///|
extern "c" fn uv_sem_copy(sem : Sem, other : Sem) = "moonbit_uv_sem_copy"

///|
extern "c" fn uv_sem_post(sem : Sem) = "moonbit_uv_sem_post"

///|
extern "c" fn uv_sem_wait(sem : Sem) = "moonbit_uv_sem_wait"

///|
extern "c" fn uv_sem_trywait(sem : Sem) -> Int = "moonbit_uv_sem_trywait"

///|
pub fn Sem::post(self : Sem) -> Unit {
  uv_sem_post(self)
}

///|
pub fn Sem::wait(self : Sem) -> Unit {
  uv_sem_wait(self)
}

///|
pub fn Sem::trywait(self : Sem) -> Unit raise Errno {
  let status = uv_sem_trywait(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub impl Share for Sem with share(self : Sem) -> Sem {
  let other = uv_sem_make()
  uv_sem_copy(self, other)
  return other
}
