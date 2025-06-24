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
extern "c" fn uv_os_uname(buffer : Bytes) -> Int = "moonbit_uv_os_uname"

///|
struct Utsname {
  sysname : String
  release : String
  version : String
  machine : String
}

///|
pub fn Utsname::sysname(self : Utsname) -> String {
  self.sysname
}

///|
pub fn Utsname::release(self : Utsname) -> String {
  self.release
}

///|
pub fn Utsname::version(self : Utsname) -> String {
  self.version
}

///|
pub fn Utsname::machine(self : Utsname) -> String {
  self.machine
}

///|
/// Retrieves system information including the system name, release, version, and
/// machine architecture.
///
/// Returns a `Utsname` structure containing system identification information.
///
/// Throws an error of type `Errno` if the underlying system call fails.
///
/// Example:
///
/// ```moonbit
/// let info = @uv.os_uname()
/// println(info.sysname())
/// println(info.release())
/// println(info.machine())
/// ```
pub fn os_uname() -> Utsname raise Errno {
  fn decode(bytes : @bytes.View) -> String {
    let buffer = @buffer.new()
    for i in 0..<bytes.length() {
      let byte = bytes[i]
      if byte == 0 {
        break
      }
      buffer.write_byte(byte)
    }
    return @encoding.decode_lossy(encoding=UTF8, buffer.contents())
  }

  let buffer = Bytes::make(256 * 4, 0)
  let status = uv_os_uname(buffer)
  if status < 0 {
    raise Errno::of_int(status)
  }
  let sysname = decode([..buffer[0:256]])
  let release = decode([..buffer[256:512]])
  let version = decode([..buffer[512:768]])
  let machine = decode([..buffer[768:1024]])
  { sysname, release, version, machine }
}

///|
extern "c" fn uv_os_tmpdir(bytes : Bytes, size : FixedArray[Int]) -> Int = "moonbit_uv_os_tmpdir"

///|
/// Retrieves the path to the system's temporary directory.
///
/// Returns a `String` containing the path to the temporary directory where
/// temporary files can be created.
///
/// Throws an error of type `Errno` if the underlying system call fails or if
/// there are insufficient resources to complete the operation.
///
/// Example:
///
/// ```moonbit
/// println(@uv.os_tmpdir())
/// ```
pub fn os_tmpdir() -> String raise Errno {
  let mut buffer = Bytes::make(64, 0)
  let length : FixedArray[Int] = [buffer.length()]
  let mut status = uv_os_tmpdir(buffer, length)
  if status == _ENOBUFS {
    buffer = Bytes::make(length[0] + 1, 0)
    status = uv_os_tmpdir(buffer, length)
  }
  if status < 0 {
    raise Errno::of_int(status)
  }
  @encoding.decode_lossy(encoding=UTF8, buffer[:length[0]])
}

///|
extern "c" fn uv_exepath(bytes : Bytes, size : FixedArray[Int]) -> Int = "moonbit_uv_exepath"

///|
pub fn exepath() -> String raise Errno {
  let mut buffer = Bytes::make(256, 0)
  let length : FixedArray[Int] = [buffer.length()]
  let mut status = uv_exepath(buffer, length)
  if status == _ENOBUFS {
    buffer = Bytes::make(length[0], 0)
    status = uv_exepath(buffer, length)
  }
  if status < 0 {
    raise Errno::of_int(status)
  }
  @encoding.decode_lossy(encoding=UTF8, buffer[:length[0]])
}

///|
extern "c" fn uv_os_homedir(bytes : Bytes, size : FixedArray[Int]) -> Int = "moonbit_uv_os_homedir"

///|
pub fn os_homedir() -> String raise Errno {
  let mut buffer = Bytes::make(256, 0)
  let length : FixedArray[Int] = [buffer.length()]
  let mut status = uv_os_homedir(buffer, length)
  if status == _ENOBUFS {
    buffer = Bytes::make(length[0], 0)
    status = uv_os_homedir(buffer, length)
  }
  if status < 0 {
    raise Errno::of_int(status)
  }
  @encoding.decode_lossy(encoding=UTF8, buffer[:length[0]])
}

///|
extern "c" fn uv_chdir(path : Bytes) -> Int = "moonbit_uv_chdir"

///|
pub fn[Ntbs : ToNtbs] chdir(path : Ntbs) -> Unit raise Errno {
  let status = uv_chdir(path.to_ntbs())
  if status < 0 {
    raise Errno::of_int(status)
  }
}
