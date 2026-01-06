/*
 * Copyright 2026 International Digital Economy Academy
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

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_rusage_get_utime_sec(uv_rusage_t *rusage) {
  return rusage->ru_utime.tv_sec;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_rusage_get_utime_usec(uv_rusage_t *rusage) {
  return rusage->ru_utime.tv_usec;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_rusage_get_stime_sec(uv_rusage_t *rusage) {
  return rusage->ru_stime.tv_sec;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_rusage_get_stime_usec(uv_rusage_t *rusage) {
  return rusage->ru_stime.tv_usec;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_maxrss(uv_rusage_t *rusage) {
  return rusage->ru_maxrss;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_ixrss(uv_rusage_t *rusage) {
  return rusage->ru_ixrss;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_idrss(uv_rusage_t *rusage) {
  return rusage->ru_idrss;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_isrss(uv_rusage_t *rusage) {
  return rusage->ru_isrss;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_minflt(uv_rusage_t *rusage) {
  return rusage->ru_minflt;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_majflt(uv_rusage_t *rusage) {
  return rusage->ru_majflt;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_nswap(uv_rusage_t *rusage) {
  return rusage->ru_nswap;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_inblock(uv_rusage_t *rusage) {
  return rusage->ru_inblock;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_oublock(uv_rusage_t *rusage) {
  return rusage->ru_oublock;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_msgsnd(uv_rusage_t *rusage) {
  return rusage->ru_msgsnd;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_msgrcv(uv_rusage_t *rusage) {
  return rusage->ru_msgrcv;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_nsignals(uv_rusage_t *rusage) {
  return rusage->ru_nsignals;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_nvcsw(uv_rusage_t *rusage) {
  return rusage->ru_nvcsw;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rusage_get_nivcsw(uv_rusage_t *rusage) {
  return rusage->ru_nivcsw;
}

MOONBIT_FFI_EXPORT
uv_rusage_t *
moonbit_uv_rusage_make(void) {
  return (uv_rusage_t *)moonbit_make_bytes(sizeof(uv_rusage_t), 0);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_getrusage(uv_rusage_t *rusage) {
  return uv_getrusage(rusage);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_getrusage_thread(uv_rusage_t *rusage) {
  return uv_getrusage_thread(rusage);
}
