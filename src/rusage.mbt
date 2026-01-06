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
struct Rusage(Rusage)

///|
#borrow(rusage)
extern "c" fn uv_rusage_get_utime_sec(rusage : Rusage) -> Int64 = "moonbit_uv_rusage_get_utime_sec"

///|
#borrow(rusage)
extern "c" fn uv_rusage_get_utime_usec(rusage : Rusage) -> Int64 = "moonbit_uv_rusage_get_utime_usec"

///|
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

///|
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
extern "c" fn uv_getrusage(rusage : Rusage) -> Int = "moonbit_uv_getrusage"

///|
pub fn getrusage() -> Rusage raise Errno {
  let rusage = uv_rusage_make()
  let status = uv_getrusage(rusage)
  if status < 0 {
    raise Errno::of_int(status)
  }
  rusage
}

///|
#borrow(rusage)
extern "c" fn uv_getrusage_thread(rusage : Rusage) -> Int = "moonbit_uv_getrusage_thread"

///|
pub fn getrusage_thread() -> Rusage raise Errno {
  let rusage = uv_rusage_make()
  let status = uv_getrusage_thread(rusage)
  if status < 0 {
    raise Errno::of_int(status)
  }
  rusage
}
