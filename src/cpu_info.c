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

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_cpu_info(uv_cpu_info_t **cpu_infos, int32_t *count) {
  int32_t result = uv_cpu_info(cpu_infos, count);
  moonbit_decref(cpu_infos);
  moonbit_decref(count);
  return result;
}

MOONBIT_FFI_EXPORT
const char *
moonbit_uv_cpu_info_get_model(uv_cpu_info_t *cpu_info, int32_t i) {
  return cpu_info[i].model;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_cpu_info_get_speed(uv_cpu_info_t *cpu_info, int32_t i) {
  return cpu_info[i].speed;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_cpu_info_get_cpu_times_user(uv_cpu_info_t *cpu_info, int32_t i) {
  return cpu_info[i].cpu_times.user;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_cpu_info_get_cpu_times_nice(uv_cpu_info_t *cpu_info, int32_t i) {
  return cpu_info[i].cpu_times.nice;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_cpu_info_get_cpu_times_sys(uv_cpu_info_t *cpu_info, int32_t i) {
  return cpu_info[i].cpu_times.sys;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_cpu_info_get_cpu_times_idle(uv_cpu_info_t *cpu_info, int32_t i) {
  return cpu_info[i].cpu_times.idle;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_cpu_info_get_cpu_times_irq(uv_cpu_info_t *cpu_info, int32_t i) {
  return cpu_info[i].cpu_times.irq;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_free_cpu_info(uv_cpu_info_t *cpu_info, int32_t count) {
  uv_free_cpu_info(cpu_info, count);
}
