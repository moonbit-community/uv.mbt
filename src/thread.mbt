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
type Thread

///|
extern "c" fn uv_thread_make() -> Thread = "moonbit_uv_thread_make"

///|
#owned(thread)
extern "c" fn uv_thread_create(
  thread : Thread,
  cb : () -> Unit,
  flags : Int,
  stack_size : UInt64,
) -> Int = "moonbit_uv_thread_create"

///|
const UV_THREAD_NO_FLAGS : Int = 0

///|
const UV_THREAD_HAS_STACK_SIZE : Int = 1

///|
pub fn Thread::new(cb : () -> Unit, stack_size? : UInt64) -> Thread raise Errno {
  let thread = uv_thread_make()
  let mut flags = UV_THREAD_NO_FLAGS
  let stack_size = if stack_size is Some(stack_size) {
    flags = flags | UV_THREAD_HAS_STACK_SIZE
    stack_size
  } else {
    0
  }
  let status = uv_thread_create(thread, cb, flags, stack_size)
  if status != 0 {
    raise Errno::of_int(status)
  }
  return thread
}

///|
#owned(thread)
extern "c" fn uv_thread_join(thread : Thread) -> Int = "moonbit_uv_thread_join"

///|
#owned(thread)
extern "c" fn uv_thread_self(thread : Thread) -> Int = "moonbit_uv_thread_self"

///|
#owned(thread, other)
extern "c" fn uv_thread_equal(thread : Thread, other : Thread) -> Int = "moonbit_uv_thread_equal"

///|
pub impl Eq for Thread with equal(self : Thread, other : Thread) -> Bool {
  return uv_thread_equal(self, other) != 0
}

///|
#owned(thread, other)
extern "c" fn uv_thread_copy(thread : Thread, other : Thread) -> Unit = "moonbit_uv_thread_copy"

///|
pub fn Thread::join(self : Thread) -> Unit raise Errno {
  let status = uv_thread_join(self)
  if status != 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn Thread::self() -> Thread raise Errno {
  let thread = uv_thread_make()
  let status = uv_thread_self(thread)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return thread
}

///|
pub fn Thread::equal(self : Thread, other : Thread) -> Bool {
  return uv_thread_equal(self, other) != 0
}

///|
pub impl Share for Thread with share(self : Thread) -> Thread {
  let other = uv_thread_make()
  uv_thread_copy(self, other)
  return other
}

///|
extern "c" fn uv_cpumask_size() -> Int = "moonbit_uv_cpumask_size"

///|
extern "c" fn uv_thread_getcpu() -> Int = "moonbit_uv_thread_getcpu"

///|
#owned(thread, cpumask, oldmask)
extern "c" fn uv_thread_setaffinity(
  thread : Thread,
  cpumask : CpuSet,
  oldmask : CpuSet,
  mask_size : Int,
) -> Int = "moonbit_uv_thread_setaffinity"

///|
#owned(thread, cpumask)
extern "c" fn uv_thread_getaffinity(
  thread : Thread,
  cpumask : CpuSet,
  mask_size : Int,
) -> Int = "moonbit_uv_thread_getaffinity"

///|
fn cpumask_size() -> Int raise Errno {
  let size = uv_cpumask_size()
  if size < 0 {
    raise Errno::of_int(size)
  }
  return size
}

///|
pub fn getcpu() -> Int raise Errno {
  let cpu = uv_thread_getcpu()
  if cpu < 0 {
    raise Errno::of_int(cpu)
  }
  return cpu
}

///|
struct CpuSet(FixedArray[Byte]) derive(Eq)

///|
pub fn CpuSet::new() -> CpuSet raise Errno {
  let length = cpumask_size()
  CpuSet(FixedArray::make(length, 0))
}

///|
pub fn CpuSet::set(self : CpuSet, cpu : Int) -> Unit {
  let self = self.0
  self[cpu / 8] = self[cpu / 8] | (1 << (cpu % 8))
}

///|
pub fn CpuSet::zero(self : CpuSet) -> Unit {
  let self = self.0
  let length = self.length()
  for i in 0..<length {
    self[i] = 0
  }
}

///|
pub fn CpuSet::clear(self : CpuSet, cpu : Int) -> Unit {
  let self = self.0
  self[cpu / 8] = self[cpu / 8] & Byte::lnot(1 << (cpu % 8))
}

///|
pub fn CpuSet::is_set(self : CpuSet, cpu : Int) -> Bool {
  let self = self.0
  (self[cpu / 8] & (1 << (cpu % 8))) != 0
}

///|
pub fn CpuSet::count(self : CpuSet) -> Int {
  let self = self.0
  let mut count = 0
  for byte in self {
    loop byte {
      0 => ()
      byte => {
        if (byte & 1) != 0 {
          count += 1
        }
        continue byte >> 1
      }
    }
  }
  count
}

///|
pub fn CpuSet::intersect(self : CpuSet, other : CpuSet) -> CpuSet {
  let self = self.0
  let other = other.0
  let length = @cmp.minimum(self.length(), other.length())
  let result : FixedArray[Byte] = FixedArray::make(length, 0)
  for i in 0..<length {
    result[i] = self[i] & other[i]
  }
  CpuSet(result)
}

///|
pub fn CpuSet::union(self : CpuSet, other : CpuSet) -> CpuSet {
  let self = self.0
  let other = other.0
  let length = @cmp.minimum(self.length(), other.length())
  let result : FixedArray[Byte] = FixedArray::make(length, 0)
  for i in 0..<length {
    result[i] = self[i] | other[i]
  }
  for i in length..<self.length() {
    result[i] = self[i]
  }
  for i in length..<other.length() {
    result[i] = other[i]
  }
  CpuSet(result)
}

///|
pub fn CpuSet::xor(self : CpuSet, other : CpuSet) -> CpuSet {
  let self = self.0
  let other = other.0
  let length = @cmp.minimum(self.length(), other.length())
  let result : FixedArray[Byte] = FixedArray::make(length, 0)
  for i in 0..<length {
    result[i] = self[i] ^ other[i]
  }
  for i in length..<self.length() {
    result[i] = self[i] ^ 0
  }
  for i in length..<other.length() {
    result[i] = other[i] ^ 0
  }
  CpuSet(result)
}

///|
pub impl BitAnd for CpuSet with land(self : CpuSet, other : CpuSet) -> CpuSet {
  return self.intersect(other)
}

///|
pub impl BitOr for CpuSet with lor(self : CpuSet, other : CpuSet) -> CpuSet {
  return self.union(other)
}

///|
pub impl BitXOr for CpuSet with lxor(self : CpuSet, other : CpuSet) -> CpuSet {
  return self.xor(other)
}

///|
pub fn Thread::set_affinity(
  self : Thread,
  cpu_set : CpuSet,
) -> Unit raise Errno {
  let old_len = cpumask_size()
  let old_set = CpuSet::new()
  let status = uv_thread_setaffinity(self, cpu_set, old_set, old_len)
  if status != 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn Thread::get_affinity(self : Thread) -> CpuSet raise Errno {
  let length = cpumask_size()
  let cpu_set = CpuSet::new()
  let status = uv_thread_getaffinity(self, cpu_set, length)
  if status != 0 {
    raise Errno::of_int(status)
  }
  cpu_set
}

///|
#owned(thread)
extern "c" fn uv_thread_detach(thread : Thread) -> Int = "moonbit_uv_thread_detach"

///|
pub fn Thread::detach(self : Thread) -> Unit raise Errno {
  let status = uv_thread_detach(self)
  if status != 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(name)
extern "c" fn uv_thread_setname(name : Bytes) -> Int = "moonbit_uv_thread_setname"

///|
pub fn Thread::set_name(name : Bytes) -> Unit raise Errno {
  let status = uv_thread_setname(name)
  if status != 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(thread, name)
extern "c" fn uv_thread_getname(
  thread : Thread,
  name : Bytes,
  size : Int,
) -> Int = "moonbit_uv_thread_getname"

///|
pub fn Thread::get_name(self : Thread) -> Bytes raise Errno {
  let buffer = Bytes::make(256, 0)
  let status = uv_thread_getname(self, buffer, buffer.length())
  if status != 0 {
    raise Errno::of_int(status)
  }

  // Find the null terminator and truncate
  let mut end = 0
  for i in 0..<buffer.length() {
    if buffer[i] == 0 {
      end = i
      break
    }
  }
  buffer.shrink(end)
  buffer
}

///|
pub enum ThreadPriority {
  Highest
  AboveNormal
  Normal
  BelowNormal
  Lowest
}

///|
extern "c" fn uv_THREAD_PRIORITY_HIGHEST() -> Int = "moonbit_uv_THREAD_PRIORITY_HIGHEST"

///|
extern "c" fn uv_THREAD_PRIORITY_ABOVE_NORMAL() -> Int = "moonbit_uv_THREAD_PRIORITY_ABOVE_NORMAL"

///|
extern "c" fn uv_THREAD_PRIORITY_NORMAL() -> Int = "moonbit_uv_THREAD_PRIORITY_NORMAL"

///|
extern "c" fn uv_THREAD_PRIORITY_BELOW_NORMAL() -> Int = "moonbit_uv_THREAD_PRIORITY_BELOW_NORMAL"

///|
extern "c" fn uv_THREAD_PRIORITY_LOWEST() -> Int = "moonbit_uv_THREAD_PRIORITY_LOWEST"

///|
let _THREAD_PRIORITY_HIGHEST : Int = uv_THREAD_PRIORITY_HIGHEST()

///|
let _THREAD_PRIORITY_ABOVE_NORMAL : Int = uv_THREAD_PRIORITY_ABOVE_NORMAL()

///|
let _THREAD_PRIORITY_NORMAL : Int = uv_THREAD_PRIORITY_NORMAL()

///|
let _THREAD_PRIORITY_BELOW_NORMAL : Int = uv_THREAD_PRIORITY_BELOW_NORMAL()

///|
let _THREAD_PRIORITY_LOWEST : Int = uv_THREAD_PRIORITY_LOWEST()

///|
fn ThreadPriority::to_int(self : ThreadPriority) -> Int {
  match self {
    Highest => _THREAD_PRIORITY_HIGHEST
    AboveNormal => _THREAD_PRIORITY_ABOVE_NORMAL
    Normal => _THREAD_PRIORITY_NORMAL
    BelowNormal => _THREAD_PRIORITY_BELOW_NORMAL
    Lowest => _THREAD_PRIORITY_LOWEST
  }
}

///|
fn ThreadPriority::of_int(priority : Int) -> ThreadPriority raise Errno {
  if priority == _THREAD_PRIORITY_HIGHEST {
    return Highest
  }
  if priority == _THREAD_PRIORITY_ABOVE_NORMAL {
    return AboveNormal
  }
  if priority == _THREAD_PRIORITY_NORMAL {
    return Normal
  }
  if priority == _THREAD_PRIORITY_BELOW_NORMAL {
    return BelowNormal
  }
  if priority == _THREAD_PRIORITY_LOWEST {
    return Lowest
  }
  raise EINVAL
}

///|
#owned(thread)
extern "c" fn uv_thread_setpriority(thread : Thread, priority : Int) -> Int = "moonbit_uv_thread_setpriority"

///|
pub fn Thread::set_priority(
  self : Thread,
  priority : ThreadPriority,
) -> Unit raise Errno {
  let status = uv_thread_setpriority(self, priority.to_int())
  if status != 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(thread, priority)
extern "c" fn uv_thread_getpriority(
  thread : Thread,
  priority : FixedArray[Int],
) -> Int = "moonbit_uv_thread_getpriority"

///|
pub fn Thread::get_priority(self : Thread) -> ThreadPriority raise Errno {
  let priority : FixedArray[Int] = [0]
  let status = uv_thread_getpriority(self, priority)
  if status != 0 {
    raise Errno::of_int(status)
  }
  ThreadPriority::of_int(priority[0])
}
