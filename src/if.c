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
#include "uv.h"
#include <stdint.h>

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
