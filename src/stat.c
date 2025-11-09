/*
 * Copyright 2025 International Digital Economy Academy
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
uint64_t
moonbit_uv_stat_get_dev(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_dev;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_mode(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_mode;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_nlink(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_nlink;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_uid(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_uid;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_gid(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_gid;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_rdev(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_rdev;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_ino(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_ino;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_size(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_size;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_blksize(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_blksize;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_blocks(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_blocks;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_flags(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_flags;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_stat_get_gen(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  uint64_t val = s->st_gen;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_atim_sec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_atim.tv_sec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_atim_nsec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_atim.tv_nsec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_mtim_sec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_mtim.tv_sec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_mtim_nsec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_mtim.tv_nsec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_ctim_sec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_ctim.tv_sec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_ctim_nsec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_ctim.tv_nsec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_birthtim_sec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_birthtim.tv_sec;
  moonbit_decref(stat_ptr);
  return val;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_stat_get_birthtim_nsec(moonbit_bytes_t stat_ptr) {
  uv_stat_t *s = (uv_stat_t *)stat_ptr;
  int64_t val = s->st_birthtim.tv_nsec;
  moonbit_decref(stat_ptr);
  return val;
}
