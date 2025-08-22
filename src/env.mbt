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
#owned(name, bytes, size)
extern "c" fn uv_os_getenv(
  name : Bytes,
  bytes : Bytes,
  size : FixedArray[Int],
) -> Int = "moonbit_uv_os_getenv"

///|
pub fn os_getenv(name : Bytes) -> Bytes? raise Errno {
  let mut buffer = Bytes::make(256, 0)
  let length : FixedArray[Int] = [buffer.length()]
  let mut status = uv_os_getenv(name, buffer, length)
  if status == _ENOENT {
    return None
  }
  if status == _ENOBUFS {
    buffer = Bytes::make(length[0], 0)
    status = uv_os_getenv(name, buffer, length)
  }
  if status < 0 {
    raise Errno::of_int(status)
  }
  buffer.shrink(length[0])
  Some(buffer)
}

///|
#owned(name, value)
extern "c" fn uv_os_setenv(name : Bytes, value : Bytes) -> Int = "moonbit_uv_os_setenv"

///|
pub fn os_setenv(name : Bytes, value : Bytes) -> Unit raise Errno {
  let status = uv_os_setenv(name, value)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(name)
extern "c" fn uv_os_unsetenv(name : Bytes) -> Int = "moonbit_uv_os_unsetenv"

///|
pub fn os_unsetenv(name : Bytes) -> Unit raise Errno {
  let status = uv_os_unsetenv(name)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
type Environ

///|
extern "c" fn uv_environ_make() -> Environ = "moonbit_uv_environ_make"

///|
#owned(environ)
extern "c" fn uv_os_environ(environ : Environ) -> Int = "moonbit_uv_os_environ"

///|
pub fn os_environ() -> Environ raise Errno {
  let environ = uv_environ_make()
  let status = uv_os_environ(environ)
  if status < 0 {
    raise Errno::of_int(status)
  }
  environ
}

///|
#borrow(environ)
extern "c" fn uv_environ_count(environ : Environ) -> Int = "moonbit_uv_environ_count"

///|
#borrow(environ)
extern "c" fn uv_environ_get_name(
  environ : Environ,
  index : Int,
) -> @c.Pointer[Byte] = "moonbit_uv_environ_get_name"

///|
#borrow(environ)
extern "c" fn uv_environ_get_value(
  environ : Environ,
  index : Int,
) -> @c.Pointer[Byte] = "moonbit_uv_environ_get_value"

///|
pub fn Environ::iter2(self : Environ) -> Iter2[Bytes, Bytes] {
  fn read_c_string(ptr : @c.Pointer[Byte]) -> Bytes {
    let buf = @buffer.new()
    for i = 0; ptr[i] != 0; i = i + 1 {
      buf.write_byte(ptr[i])
    }
    buf.contents()
  }

  let count = uv_environ_count(self)
  Iter2::new(fn(yield_) {
    for i in 0..<count {
      let name = read_c_string(uv_environ_get_name(self, i))
      let value = read_c_string(uv_environ_get_value(self, i))
      match yield_(name, value) {
        IterEnd => break IterEnd
        IterContinue => ()
      }
    } else {
      IterContinue
    }
  })
}
