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
#owned(buffer)
extern "c" fn uv_os_uname(buffer : Bytes) -> Int = "moonbit_uv_os_uname"

///|
struct Utsname {
  sysname : @bytes.View
  release : @bytes.View
  version : @bytes.View
  machine : @bytes.View
}

///|
pub fn Utsname::sysname(self : Utsname) -> @bytes.View {
  self.sysname
}

///|
pub fn Utsname::release(self : Utsname) -> @bytes.View {
  self.release
}

///|
pub fn Utsname::version(self : Utsname) -> @bytes.View {
  self.version
}

///|
pub fn Utsname::machine(self : Utsname) -> @bytes.View {
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
  let buffer = Bytes::make(256 * 4, 0)
  let status = uv_os_uname(buffer)
  if status < 0 {
    raise Errno::of_int(status)
  }
  fn shrink(s : @bytes.View) -> @bytes.View {
    let mut len = 0
    for b in s {
      if b == 0 {
        break
      }
      len = len + 1
    }
    s[:len]
  }

  let sysname = shrink(buffer[0:256])
  let release = shrink(buffer[256:512])
  let version = shrink(buffer[512:768])
  let machine = shrink(buffer[768:1024])
  { sysname, release, version, machine }
}

///|
#owned(bytes, size)
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
pub fn os_tmpdir() -> Bytes raise Errno {
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
  buffer.shrink(length[0])
  buffer
}

///|
#owned(bytes, size)
extern "c" fn uv_exepath(bytes : Bytes, size : FixedArray[Int]) -> Int = "moonbit_uv_exepath"

///|
pub fn exepath() -> Bytes raise Errno {
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
  buffer.shrink(length[0])
  buffer
}

///|
#owned(bytes, size)
extern "c" fn uv_os_homedir(bytes : Bytes, size : FixedArray[Int]) -> Int = "moonbit_uv_os_homedir"

///|
pub fn os_homedir() -> Bytes raise Errno {
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
  buffer.shrink(length[0])
  buffer
}

///|
#owned(path)
extern "c" fn uv_chdir(path : Bytes) -> Int = "moonbit_uv_chdir"

///|
pub fn chdir(path : Bytes) -> Unit raise Errno {
  let status = uv_chdir(path)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
struct CpuInfo {
  model : Bytes
  speed : Int
  cpu_times : CpuTimes
}

///|
pub fn CpuInfo::model(self : CpuInfo) -> Bytes {
  self.model
}

///|
pub fn CpuInfo::speed(self : CpuInfo) -> Int {
  self.speed
}

///|
pub fn CpuInfo::cpu_times(self : CpuInfo) -> CpuTimes {
  self.cpu_times
}

///|
struct CpuTimes {
  user : UInt64
  nice : UInt64
  sys : UInt64
  idle : UInt64
  irq : UInt64
}

///|
pub fn CpuTimes::user(self : CpuTimes) -> UInt64 {
  self.user
}

///|
pub fn CpuTimes::nice(self : CpuTimes) -> UInt64 {
  self.nice
}

///|
pub fn CpuTimes::sys(self : CpuTimes) -> UInt64 {
  self.sys
}

///|
pub fn CpuTimes::idle(self : CpuTimes) -> UInt64 {
  self.idle
}

///|
pub fn CpuTimes::irq(self : CpuTimes) -> UInt64 {
  self.irq
}

///|
#owned(cpu_infos, count)
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
    buffer.contents()
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
/// for cpu_info in cpu_infos {
///   println(cpu_info.model())
/// }
/// ```
pub fn cpu_info() -> Array[CpuInfo] raise Errno {
  let uv_cpu_infos : FixedArray[@c.Pointer[CpuInfo]] = [@c.Pointer::null()]
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

///|
pub extern "c" fn get_free_memory() -> UInt64 = "moonbit_uv_get_free_memory"

///|
pub extern "c" fn get_total_memory() -> UInt64 = "moonbit_uv_get_total_memory"

///|
pub extern "c" fn get_constrained_memory() -> UInt64 = "moonbit_uv_get_constrained_memory"

///|
pub extern "c" fn get_available_memory() -> UInt64 = "moonbit_uv_get_available_memory"

///|
type Passwd

///|
extern "c" fn uv_passwd_make() -> Passwd = "moonbit_uv_passwd_make"

///|
#owned(passwd)
pub extern "c" fn Passwd::username(passwd : Passwd) -> Bytes = "moonbit_uv_passwd_get_username"

///|
#owned(passwd)
pub extern "c" fn Passwd::uid(passwd : Passwd) -> Uid = "moonbit_uv_passwd_get_uid"

///|
#owned(passwd)
pub extern "c" fn Passwd::gid(passwd : Passwd) -> Gid = "moonbit_uv_passwd_get_gid"

///|
#owned(passwd)
pub extern "c" fn Passwd::shell(passwd : Passwd) -> Bytes = "moonbit_uv_passwd_get_shell"

///|
#owned(passwd)
extern "c" fn uv_os_get_passwd(passwd : Passwd) -> Int = "moonbit_uv_os_get_passwd"

///|
/// ```
/// let passwd = @uv.os_get_passwd()
/// println(passwd.username())
/// println(passwd.uid().inner())
/// println(passwd.gid().inner())
/// println(passwd.shell())
/// ```
pub fn os_get_passwd() -> Passwd raise Errno {
  let passwd = uv_passwd_make()
  let status = uv_os_get_passwd(passwd)
  if status < 0 {
    raise Errno::of_int(status)
  }
  passwd
}

///|
pub struct Timeval {
  sec : Int64
  usec : Int64
}

///|
struct Rusage(Rusage)

///|
#borrow(rusage)
extern "c" fn uv_rusage_get_utime_sec(rusage : Rusage) -> Int64 = "moonbit_uv_rusage_get_utime_sec"

///|
#borrow(rusage)
extern "c" fn uv_rusage_get_utime_usec(rusage : Rusage) -> Int64 = "moonbit_uv_rusage_get_utime_usec"

pub fn Rusage::utime(rusage : Rusage) -> Timeval {
  let sec = uv_rusage_get_utime_sec(rusage)
  let usec = uv_rusage_get_utime_usec(rusage)
  { sec, usec }
}

///|
#borrow(rusage)
extern "c" fn uv_rusage_get_stime_sec(rusage : Rusage) -> Int64 = "moonbit_uv_rusage_get_stime_sec"

///|
#borrow(rusage)
extern "c" fn uv_rusage_get_stime_usec(rusage : Rusage) -> Int64 = "moonbit_uv_rusage_get_stime_usec"

pub fn Rusage::stime(rusage : Rusage) -> Timeval {
  let sec = uv_rusage_get_stime_sec(rusage)
  let usec = uv_rusage_get_stime_usec(rusage)
  { sec, usec }
}

///|
#borrow(rusage)
pub extern "c" fn Rusage::maxrss(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_maxrss"

///|
#borrow(rusage)
pub extern "c" fn Rusage::ixrss(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_ixrss"

///|
#borrow(rusage)
pub extern "c" fn Rusage::idrss(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_idrss"

///|
#borrow(rusage)
pub extern "c" fn Rusage::isrss(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_isrss"

///|
#borrow(rusage)
pub extern "c" fn Rusage::minflt(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_minflt"

///|
#borrow(rusage)
pub extern "c" fn Rusage::majflt(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_majflt"

///|
#borrow(rusage)
pub extern "c" fn Rusage::nswap(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_nswap"

///|
#borrow(rusage)
pub extern "c" fn Rusage::inblock(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_inblock"

///|
#borrow(rusage)
pub extern "c" fn Rusage::oublock(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_oublock"

///|
#borrow(rusage)
pub extern "c" fn Rusage::msgsnd(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_msgsnd"

///|
#borrow(rusage)
pub extern "c" fn Rusage::msgrcv(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_msgrcv"

///|
#borrow(rusage)
pub extern "c" fn Rusage::nsignals(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_nsignals"

///|
#borrow(rusage)
pub extern "c" fn Rusage::nvcsw(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_nvcsw"

///|
#borrow(rusage)
pub extern "c" fn Rusage::nivcsw(rusage : Rusage) -> Int = "moonbit_uv_rusage_get_nivcsw"

///|
extern "c" fn uv_rusage_make() -> Rusage = "moonbit_uv_rusage_make"

///|
#borrow(rusage)
extern "c" fn uv_getrusage(rusage : Rusage) -> Int = "uv_getrusage"

///|
pub fn getrusage() -> Rusage raise Errno {
  let rusage = uv_rusage_make()
  let status = uv_getrusage(rusage)
  if status < 0 {
    raise Errno::of_int(status)
  }
  rusage
}
