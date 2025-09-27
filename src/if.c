/* Copyright 2025 International Digital Economy Academy
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "moonbit.h"
#include "uv#include#uv.h"
#include <stdint.h>
#include <string.h>

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_IF_NAMESIZE(void) {
  return UV_IF_NAMESIZE;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_if_indextoname(
  uint32_t ifindex,
  moonbit_bytes_t ifname,
  int32_t *ifsize
) {
  size_t size = *ifsize;
  int status = uv_if_indextoname(ifindex, (char *)ifname, &size);
  *ifsize = size;
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_if_indextoiid(uint32_t ifindex, moonbit_bytes_t ifname) {
  size_t size = Moonbit_array_length(ifname);
  int status = uv_if_indextoiid(ifindex, (char *)ifname, &size);
  if (status < 0) {
    return status;
  }
  return size;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_interface_addresses(
  uv_interface_address_t **addresses,
  int32_t *count
) {
  int status = uv_interface_addresses(addresses, count);
  moonbit_decref(addresses);
  moonbit_decref(count);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_free_interface_addresses(
  uv_interface_address_t *addresses,
  int32_t count
) {
  uv_free_interface_addresses(addresses, count);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t
moonbit_uv_interface_addresses_name(
  uv_interface_address_t *address,
  int32_t index
) {
  size_t size = strlen(address[index].name);
  moonbit_bytes_t name = moonbit_make_bytes(size, 0);
  memcpy(name, address[index].name, size);
  return name;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_interface_addresses_phys_addr(
  uv_interface_address_t *address,
  int32_t index
) {
  uint64_t phys_addr = 0;
  phys_addr |= ((uint64_t)(unsigned char)address[index].phys_addr[0]) << 40;
  phys_addr |= ((uint64_t)(unsigned char)address[index].phys_addr[1]) << 32;
  phys_addr |= ((uint64_t)(unsigned char)address[index].phys_addr[2]) << 24;
  phys_addr |= ((uint64_t)(unsigned char)address[index].phys_addr[3]) << 16;
  phys_addr |= ((uint64_t)(unsigned char)address[index].phys_addr[4]) << 8;
  phys_addr |= ((uint64_t)(unsigned char)address[index].phys_addr[5]) << 0;
  return phys_addr;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_interface_addresses_is_internal(
  uv_interface_address_t *address,
  int32_t index
) {
  return address[index].is_internal;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t
moonbit_uv_interface_addresses_address(
  uv_interface_address_t *address,
  int32_t index
) {
  moonbit_bytes_t sockaddr_storage =
    moonbit_make_bytes(sizeof(address[index].address), 0);
  memcpy(
    sockaddr_storage, &address[index].address, sizeof(address[index].address)
  );
  return sockaddr_storage;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t
moonbit_uv_interface_addresses_netmask(
  uv_interface_address_t *address,
  int32_t index
) {
  moonbit_bytes_t sockaddr_storage =
    moonbit_make_bytes(sizeof(address[index].netmask), 0);
  memcpy(
    sockaddr_storage, &address[index].netmask, sizeof(address[index].netmask)
  );
  return sockaddr_storage;
}
