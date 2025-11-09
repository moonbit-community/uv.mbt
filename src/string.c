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
#include <stdint.h>

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_utf16_length_as_wtf8(moonbit_string_t utf16) {
  size_t utf16_length = Moonbit_array_length(utf16);
  size_t wtf8_length = uv_utf16_length_as_wtf8(utf16, (ssize_t)utf16_length);
  moonbit_decref(utf16);
  return wtf8_length;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_utf16_to_wtf8(moonbit_string_t utf16, moonbit_bytes_t wtf8) {
  size_t utf16_length = Moonbit_array_length(utf16);
  char *wtf8_buf = (char *)wtf8;
  size_t wtf8_length = Moonbit_array_length(wtf8);
  int32_t status =
    uv_utf16_to_wtf8(utf16, (ssize_t)utf16_length, &wtf8_buf, &wtf8_length);
  moonbit_decref(utf16);
  moonbit_decref(wtf8);
  return status;
}

MOONBIT_FFI_EXPORT
int64_t
moonbit_uv_wtf8_length_as_utf16(moonbit_bytes_t wtf8) {
  char *wtf8_buf = (char *)wtf8;
  ssize_t utf16_length = uv_wtf8_length_as_utf16(wtf8_buf);
  moonbit_decref(wtf8);
  return utf16_length;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_wtf8_to_utf16(moonbit_bytes_t wtf8, moonbit_string_t utf16) {
  char *wtf8_buf = (char *)wtf8;
  size_t utf16_length = Moonbit_array_length(utf16);
  uv_wtf8_to_utf16(wtf8_buf, utf16, utf16_length);
  uint32_t meta = Moonbit_object_header(utf16)->meta;
  meta &= ~(((uint32_t)1 << 28) - 1);                     // Clear length bits
  meta |= (utf16_length - 1) & (((uint32_t)1 << 28) - 1); // Set new length
  Moonbit_object_header(utf16)->meta = meta;
  moonbit_decref(utf16);
  moonbit_decref(wtf8);
}
