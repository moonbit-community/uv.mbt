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
#include <stdlib.h>
#include <string.h>

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_exepath(moonbit_bytes_t buffer, int32_t *size) {
  size_t size_value = *size;
  int32_t status = uv_exepath((char *)buffer, &size_value);
  *size = size_value;
  moonbit_decref(buffer);
  moonbit_decref(size);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_homedir(moonbit_bytes_t buffer, int32_t *size) {
  size_t size_value = *size;
  int32_t status = uv_os_homedir((char *)buffer, &size_value);
  *size = size_value;
  moonbit_decref(buffer);
  moonbit_decref(size);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_uname(moonbit_bytes_t buffer) {
  int32_t status = uv_os_uname((uv_utsname_t *)buffer);
  moonbit_decref(buffer);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_tmpdir(moonbit_bytes_t buffer, int32_t *size) {
  size_t size_value = *size;
  int32_t status = uv_os_tmpdir((char *)buffer, &size_value);
  *size = size_value;
  moonbit_decref(buffer);
  moonbit_decref(size);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_cwd(moonbit_bytes_t buffer, int32_t *length) {
  size_t size = *length;
  int status = uv_cwd((char *)buffer, &size);
  *length = size;
  moonbit_decref(buffer);
  moonbit_decref(length);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_chdir(moonbit_bytes_t path) {
  int status = uv_chdir((const char *)path);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT uint64_t
moonbit_uv_get_free_memory(void) {
  return uv_get_available_memory();
}

MOONBIT_FFI_EXPORT uint64_t
moonbit_uv_get_total_memory(void) {
  return uv_get_available_memory();
}

MOONBIT_FFI_EXPORT uint64_t
moonbit_uv_get_constrained_memory(void) {
  return uv_get_available_memory();
}

MOONBIT_FFI_EXPORT uint64_t
moonbit_uv_get_available_memory(void) {
  return uv_get_available_memory();
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_gethostname(moonbit_bytes_t name, int32_t *size) {
  size_t size_value = *size;
  int32_t status = uv_os_gethostname((char *)name, &size_value);
  *size = size_value;
  moonbit_decref(name);
  moonbit_decref(size);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_uptime(double *uptime) {
  return uv_uptime(uptime);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_resident_set_memory(uint64_t *rss) {
  size_t rss_value = (size_t)*rss;
  int32_t status = uv_resident_set_memory(&rss_value);
  *rss = (uint64_t)rss_value;
  moonbit_decref(rss);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_loadavg(double avg[3]) {
  uv_loadavg(avg);
  moonbit_decref(avg);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_available_parallelism(void) {
  return uv_available_parallelism();
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_getpriority(int32_t pid, int32_t *priority) {
  int32_t priority_value = *priority;
  int32_t status = uv_os_getpriority(pid, &priority_value);
  *priority = priority_value;
  moonbit_decref(priority);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_setpriority(int32_t pid, int32_t priority) {
  return uv_os_setpriority(pid, priority);
}
