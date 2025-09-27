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
struct IfIndex(UInt)

///|
pub impl Show for IfIndex with output(self : IfIndex, logger : &Logger) -> Unit {
  logger.write_string(self.0.to_string())
}

///|
pub impl ToJson for IfIndex with to_json(self : IfIndex) -> Json {
  return self.0.to_json()
}

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

///|
struct PhysAddr(UInt64)

///|
pub impl Show for PhysAddr with output(self : PhysAddr, logger : &Logger) -> Unit {
  let b0 = (self.0 >> 40) & 0xff
  let b1 = (self.0 >> 32) & 0xff
  let b2 = (self.0 >> 24) & 0xff
  let b3 = (self.0 >> 16) & 0xff
  let b4 = (self.0 >> 8) & 0xff
  let b5 = self.0 & 0xff
  logger.write_string(b0.to_string(radix=16).pad_start(2, '0'))
  logger.write_char(':')
  logger.write_string(b1.to_string(radix=16).pad_start(2, '0'))
  logger.write_char(':')
  logger.write_string(b2.to_string(radix=16).pad_start(2, '0'))
  logger.write_char(':')
  logger.write_string(b3.to_string(radix=16).pad_start(2, '0'))
  logger.write_char(':')
  logger.write_string(b4.to_string(radix=16).pad_start(2, '0'))
  logger.write_char(':')
  logger.write_string(b5.to_string(radix=16).pad_start(2, '0'))
}

///|
pub impl ToJson for PhysAddr with to_json(self : PhysAddr) -> Json {
  return self.to_string().to_json()
}

///|
pub struct InterfaceAddress {
  name : Bytes
  phys_addr : PhysAddr
  is_internal : Bool
  address : Sockaddr
  netmask : Sockaddr
} derive(ToJson)

///|
extern "c" fn uv_interface_addresses_name(
  address : @c.Pointer[InterfaceAddress],
  index : Int,
) -> Bytes = "moonbit_uv_interface_addresses_name"

///|
extern "c" fn uv_interface_addresses_phys_addr(
  address : @c.Pointer[InterfaceAddress],
  index : Int,
) -> UInt64 = "moonbit_uv_interface_addresses_phys_addr"

///|
extern "c" fn uv_interface_addresses_is_internal(
  address : @c.Pointer[InterfaceAddress],
  index : Int,
) -> Int = "moonbit_uv_interface_addresses_is_internal"

///|
extern "c" fn uv_interface_addresses_address(
  address : @c.Pointer[InterfaceAddress],
  index : Int,
) -> Sockaddr = "moonbit_uv_interface_addresses_address"

///|
extern "c" fn uv_interface_addresses_netmask(
  address : @c.Pointer[InterfaceAddress],
  index : Int,
) -> Sockaddr = "moonbit_uv_interface_addresses_netmask"

///|
impl @c.Load for InterfaceAddress with load(
  self : @c.Pointer[InterfaceAddress],
  index : Int,
) -> InterfaceAddress {
  return InterfaceAddress::{
    name: uv_interface_addresses_name(self, index),
    phys_addr: uv_interface_addresses_phys_addr(self, index),
    is_internal: uv_interface_addresses_is_internal(self, index) != 0,
    address: uv_interface_addresses_address(self, index),
    netmask: uv_interface_addresses_netmask(self, index),
  }
}

///|
#owned(addresses, count)
extern "c" fn uv_interface_addresses(
  addresses : Ref[@c.Pointer[InterfaceAddress]],
  count : Ref[Int],
) -> Int = "moonbit_uv_interface_addresses"

///|
extern "c" fn uv_free_interface_addresses(
  addresses : @c.Pointer[InterfaceAddress],
  count : Int,
) = "moonbit_uv_free_interface_addresses"

///|
pub fn interface_addresses() -> FixedArray[InterfaceAddress] raise {
  let addresses = Ref::new(@c.Pointer::null())
  let count : Ref[Int] = Ref::new(0)
  let status = uv_interface_addresses(addresses, count)
  if status < 0 {
    raise Errno::of_int(status)
  }
  let result = FixedArray::makei(count.val, i => addresses.val[i])
  uv_free_interface_addresses(addresses.val, count.val)
  return result
}
