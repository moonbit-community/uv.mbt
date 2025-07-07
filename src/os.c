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
#include <stdlib.h>

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
void
moonbit_uv_setup_args(moonbit_bytes_t *argv) {
  // `argv` is marked as borrowed on MoonBit side, so there is no need to decref
  // it here.
  int argc = Moonbit_array_length(argv);
  char **args = malloc(sizeof(char *) * (size_t)argc);
  for (int i = 0; i < argc; i++) {
    // `argv` in MoonBit is not a null-terminated byte sequence, so we need to
    // add a '\0' at the end of each argument.
    moonbit_bytes_t arg = argv[i];
    size_t arglen = Moonbit_array_length(arg);
    args[i] = malloc(arglen + 1);
    memcpy(args[i], arg, arglen);
    args[i][arglen] = '\0';
  }
  // `libuv` may take ownership of `args` here.
  uv_setup_args(argc, args);
  // `libuv` may return a copy of `args` here, but we discard it anyway since we
  // copied the arguments above.
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
void
moonbit_uv_sleep(uint32_t milliseconds) {
  uv_sleep(milliseconds);
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_hrtime(void) {
  uint64_t hrtime = uv_hrtime();
  return hrtime;
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
