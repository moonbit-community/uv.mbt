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
type Thread

///|
extern "c" fn uv_thread_make() -> Thread = "moonbit_uv_thread_make"

///|
extern "c" fn uv_thread_create(thread : Thread, cb : () -> Unit) -> Int = "moonbit_uv_thread_create"

///|
pub fn Thread::new(cb : () -> Unit) -> Thread raise Errno {
  let thread = uv_thread_make()
  let status = uv_thread_create(thread, cb)
  if status != 0 {
    raise Errno::of_int(status)
  }
  return thread
}

///|
extern "c" fn uv_thread_join(thread : Thread) -> Int = "moonbit_uv_thread_join"

///|
extern "c" fn uv_thread_self(thread : Thread) -> Int = "moonbit_uv_thread_self"

///|
extern "c" fn uv_thread_equal(thread : Thread, other : Thread) -> Int = "moonbit_uv_thread_equal"

///|
pub impl Eq for Thread with op_equal(self : Thread, other : Thread) -> Bool {
  return uv_thread_equal(self, other) != 0
}

///|
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
extern "c" fn uv_thread_setaffinity(
  thread : Thread,
  cpumask : CpuSet,
  oldmask : CpuSet,
  mask_size : Int,
) -> Int = "moonbit_uv_thread_setaffinity"

///|
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
type CpuSet FixedArray[Byte]

///|
pub fn CpuSet::new() -> CpuSet raise Errno {
  let length = cpumask_size()
  CpuSet(FixedArray::make(length, 0))
}

///|
pub fn CpuSet::set(self : CpuSet, cpu : Int) -> Unit {
  let self = self.inner()
  self[cpu / 8] = self[cpu / 8] | (1 << (cpu % 8))
}

///|
pub fn CpuSet::zero(self : CpuSet) -> Unit {
  let self = self.inner()
  let length = self.length()
  for i in 0..<length {
    self[i] = 0
  }
}

///|
pub fn CpuSet::clear(self : CpuSet, cpu : Int) -> Unit {
  let self = self.inner()
  self[cpu / 8] = self[cpu / 8] & Byte::lnot(1 << (cpu % 8))
}

///|
pub fn CpuSet::is_set(self : CpuSet, cpu : Int) -> Bool {
  let self = self.inner()
  (self[cpu / 8] & (1 << (cpu % 8))) != 0
}

///|
pub fn CpuSet::count(self : CpuSet) -> Int {
  let self = self.inner()
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
pub fn CpuSet::equal(self : CpuSet, other : CpuSet) -> Bool {
  let self = self.inner()
  let other = other.inner()
  if self.length() != other.length() {
    return false
  }
  for i in 0..<self.length() {
    if self[i] != other[i] {
      return false
    }
  }
  true
}

///|
pub impl Eq for CpuSet with op_equal(self : CpuSet, other : CpuSet) -> Bool {
  self.equal(other)
}

///|
pub fn CpuSet::intersect(self : CpuSet, other : CpuSet) -> CpuSet {
  let self = self.inner()
  let other = other.inner()
  let length = @cmp.minimum(self.length(), other.length())
  let result : FixedArray[Byte] = FixedArray::make(length, 0)
  for i in 0..<length {
    result[i] = self[i] & other[i]
  }
  CpuSet(result)
}

///|
pub fn CpuSet::union(self : CpuSet, other : CpuSet) -> CpuSet {
  let self = self.inner()
  let other = other.inner()
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
  let self = self.inner()
  let other = other.inner()
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
pub impl Show for CpuSet with output(self : CpuSet, logger : &Logger) -> Unit {
  for i in 0..<self.count() {
    if self.is_set(i) {
      logger.write_object(i)
    }
  }
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
