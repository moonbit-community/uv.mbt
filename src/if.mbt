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
extern "c" fn uv_IF_NAMESIZE() -> Int = "moonbit_uv_IF_NAMESIZE"

///|
let _IF_NAMESIZE : Int = uv_IF_NAMESIZE()

///|
struct IfIndex(UInt) derive(Show, ToJson)

///|
#borrow(name, size)
extern "c" fn uv_if_indextoname(
  index : UInt,
  name : FixedArray[Byte],
  size : Ref[Int],
) -> Int = "moonbit_uv_if_indextoname"

///|
pub fn IfIndex::to_name(self : IfIndex) -> Bytes raise {
  let mut name : FixedArray[Byte] = FixedArray::make(_IF_NAMESIZE, 0)
  let size : Ref[Int] = Ref::new(name.length())
  let mut status = uv_if_indextoname(self.0, name, size)
  if status == _ENOBUFS {
    name = FixedArray::make(size.val, 0)
    status = uv_if_indextoname(self.0, name, size)
  }
  if status < 0 {
    raise Errno::of_int(status)
  }
  let buf : FixedArray[Byte] = FixedArray::make(size.val, 0)
  buf.unsafe_blit(0, name, 0, size.val)
  return buf.unsafe_reinterpret_as_bytes()
}

///|
#borrow(iid)
extern "c" fn uv_if_indextoiid(index : UInt, iid : FixedArray[Byte]) -> Int = "moonbit_uv_if_indextoiid"

///|
pub fn IfIndex::to_iid(self : IfIndex) -> Bytes raise {
  let mut iid : FixedArray[Byte] = FixedArray::make(16, 0)
  let mut status = uv_if_indextoiid(self.0, iid)
  if status == _ENOBUFS {
    iid = FixedArray::make(status, 0)
    status = uv_if_indextoiid(self.0, iid)
  }
  if status < 0 {
    raise Errno::of_int(status)
  }
  let buf : FixedArray[Byte] = FixedArray::make(status, 0)
  buf.unsafe_blit(0, iid, 0, status)
  return buf.unsafe_reinterpret_as_bytes()
}
