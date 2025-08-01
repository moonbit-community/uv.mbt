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
pub fn chdir(path : Bytes) -> Unit raise Errno {
  let status = uv_chdir(path)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub struct CpuInfo {
  model : String
  speed : Int
  cpu_times : CpuTimes
} derive(Show, ToJson)

///|
pub struct CpuTimes {
  user : UInt64
  nice : UInt64
  sys : UInt64
  idle : UInt64
  irq : UInt64
} derive(Show, ToJson)

///|
extern "c" fn uv_cpu_info(
  cpu_infos : FixedArray[@c.Pointer[CpuInfo]],
  count : FixedArray[Int],
) -> Int = "moonbit_uv_cpu_info"

///|
extern "c" fn uv_cpu_info_get_model(
  cpu_info : @c.Pointer[CpuInfo],
  index : Int,
) -> @c.Pointer[Byte] = "moonbit_uv_cpu_info_get_model"

///|
extern "c" fn uv_cpu_info_get_speed(
  cpu_info : @c.Pointer[CpuInfo],
  index : Int,
) -> Int = "moonbit_uv_cpu_info_get_speed"

///|
extern "c" fn uv_cpu_info_get_cpu_times_user(
  cpu_info : @c.Pointer[CpuInfo],
  index : Int,
) -> UInt64 = "moonbit_uv_cpu_info_get_cpu_times_user"

///|
extern "c" fn uv_cpu_info_get_cpu_times_nice(
  cpu_info : @c.Pointer[CpuInfo],
  index : Int,
) -> UInt64 = "moonbit_uv_cpu_info_get_cpu_times_nice"

///|
extern "c" fn uv_cpu_info_get_cpu_times_sys(
  cpu_info : @c.Pointer[CpuInfo],
  index : Int,
) -> UInt64 = "moonbit_uv_cpu_info_get_cpu_times_sys"

///|
extern "c" fn uv_cpu_info_get_cpu_times_idle(
  cpu_info : @c.Pointer[CpuInfo],
  index : Int,
) -> UInt64 = "moonbit_uv_cpu_info_get_cpu_times_idle"

///|
extern "c" fn uv_cpu_info_get_cpu_times_irq(
  cpu_info : @c.Pointer[CpuInfo],
  index : Int,
) -> UInt64 = "moonbit_uv_cpu_info_get_cpu_times_irq"

///|
impl @c.Load for CpuInfo with load(self : @c.Pointer[CpuInfo], index : Int) -> CpuInfo {
  let model = {
    let buffer = @buffer.new()
    let pointer = uv_cpu_info_get_model(self, index)
    for i = 0; pointer[i] != 0; i = i + 1 {
      buffer.write_byte(pointer[i])
    }
    @encoding.decode_lossy(encoding=UTF8, buffer.contents())
  }
  let speed = uv_cpu_info_get_speed(self, index)
  let cpu_times = {
    user: uv_cpu_info_get_cpu_times_user(self, index),
    nice: uv_cpu_info_get_cpu_times_nice(self, index),
    sys: uv_cpu_info_get_cpu_times_sys(self, index),
    idle: uv_cpu_info_get_cpu_times_idle(self, index),
    irq: uv_cpu_info_get_cpu_times_irq(self, index),
  }
  { model, speed, cpu_times }
}

///|
extern "c" fn uv_free_cpu_info(cpu_infos : @c.Pointer[CpuInfo], count : Int) = "moonbit_uv_free_cpu_info"

///|
/// Returns current CPU information.
///
/// Example:
///
/// ```moonbit
/// let cpu_infos = @uv.cpu_info()
/// println(cpu_infos)
/// ```
pub fn cpu_info() -> Array[CpuInfo] raise Errno {
  let uv_cpu_infos : FixedArray[@c.Pointer[CpuInfo]] = [@c.null()]
  let count : FixedArray[Int] = [0]
  let status = uv_cpu_info(uv_cpu_infos, count)
  if status < 0 {
    raise Errno::of_int(status)
  }
  let uv_cpu_infos = uv_cpu_infos[0]
  let count = count[0]
  let cpu_infos = []
  for i in 0..<count {
    cpu_infos.push(uv_cpu_infos[i])
  }
  uv_free_cpu_info(uv_cpu_infos, count)
  cpu_infos
}
