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

#ifndef MOONBIT_UV_MUTEX_H
#define MOONBIT_UV_MUTEX_H

#include "uv#include#uv.h"

typedef struct moonbit_uv_mutex_s {
#if __STDC_VERSION__ >= 201112L
  struct {
    _Atomic int32_t arc;
    uv_mutex_t object;
  } *block;
#else
  struct {
    int32_t arc;
    uv_mutex_t mutex;
    uv_mutex_t object;
  } *block;
#endif
} moonbit_uv_mutex_t;

#endif // MOONBIT_UV_MUTEX_H
