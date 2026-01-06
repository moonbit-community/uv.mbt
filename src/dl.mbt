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
type Lib

///|
extern "c" fn uv_lib_make() -> Lib = "moonbit_uv_lib_make"

///|
#owned(filename, lib)
extern "c" fn uv_dlopen(filename : Bytes, lib : Lib) -> Int = "moonbit_uv_dlopen"

///|
#owned(lib, name, ptr)
extern "c" fn uv_dlsym(
  lib : Lib,
  name : Bytes,
  ptr : Ref[@c.Pointer[Unit]],
) -> Int = "moonbit_uv_dlsym"

///|
#owned(lib)
extern "c" fn uv_dlerror(lib : Lib) -> @c.Pointer[Byte] = "moonbit_uv_dlerror"

///|
suberror DlError Bytes

///|
pub fn Lib::open(filename : Bytes) -> Lib raise DlError {
  let lib = uv_lib_make()
  if uv_dlopen(filename, lib) != 0 {
    let ptr = uv_dlerror(lib)
    let buf = @buffer.new()
    for i = 0; ptr[i] != 0; i = i + 1 {
      buf.write_byte(ptr[i])
    }
    raise DlError(buf.to_bytes())
  }
  lib
}

///|
pub fn[T] Lib::symbol(lib : Lib, name : Bytes) -> T? {
  let ptr = Ref::new(@c.Pointer::null())
  if uv_dlsym(lib, name, ptr) != 0 {
    return None
  }
  ptr.val.unwrap()
}
