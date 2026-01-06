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
uint32_t
moonbit_uv_version_major(void) {
  return UV_VERSION_MAJOR;
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_uv_version_minor(void) {
  return UV_VERSION_MINOR;
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_uv_version_patch(void) {
  return UV_VERSION_PATCH;
}

MOONBIT_FFI_EXPORT
const char *
moonbit_uv_version_suffix(void) {
  return UV_VERSION_SUFFIX;
}

MOONBIT_FFI_EXPORT
const char *
moonbit_uv_version_string(void) {
  return uv_version_string();
}
