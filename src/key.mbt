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
type Key

///|
extern "c" fn uv_key_make() -> Key = "moonbit_uv_key_make"

///|
#owned(key)
extern "c" fn uv_key_create(key : Key) -> Int = "moonbit_uv_key_create"

///|
pub fn Key::new() -> Key raise Errno {
  let key = uv_key_make()
  let status = uv_key_create(key)
  if status != 0 {
    raise Errno::of_int(status)
  }
  return key
}

///|
#owned(key)
extern "c" fn uv_key_get(key : Key) -> @c.Pointer[Unit] = "moonbit_uv_key_get"

///|
#owned(key, value)
extern "c" fn uv_key_set(key : Key, value : @c.Pointer[Unit]) = "moonbit_uv_key_set"

///|
fn[T] @c.Pointer::unwrap(self : @c.Pointer[Unit]) -> T = "%identity"

///|
fn[T] @c.Pointer::wrap(self : T) -> @c.Pointer[Unit] = "%identity"

///|
pub fn[T] Key::get(self : Key) -> T? {
  let ptr = uv_key_get(self)
  if ptr.is_null() {
    None
  } else {
    Some(ptr.cast().unwrap())
  }
}

///|
pub fn[T] Key::set(self : Key, value : T) -> Unit {
  uv_key_set(self, @c.Pointer::wrap(value))
}
