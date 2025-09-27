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
#include <stdlib.h>

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_setup_args(moonbit_bytes_t *argv) {
  size_t argc = Moonbit_array_length(argv);
  size_t size = 0;
  for (size_t i = 0; i < argc; i++) {
    size += Moonbit_array_length(argv[i]) + 1;
  }
  size += (argc + 1) * sizeof(char *);
  char **c_argv = (char **)malloc(size);
  if (c_argv == NULL) {
    moonbit_decref(argv);
    return UV_ENOMEM;
  }
  memset(c_argv, 0, size);
  char *s = (char *)&c_argv[argc + 1];
  size = strlen((const char *)argv[0]) + 1;
  for (size_t i = 0; i < argc; i++) {
    size = strlen((const char *)argv[i]) + 1;
    memcpy(s, (const char *)argv[i], size);
    c_argv[i] = s;
    s += size;
  }
  c_argv[argc] = NULL;
  uv_setup_args(argc, c_argv);
  moonbit_decref(argv);
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_get_process_title(moonbit_bytes_t buffer) {
  size_t size = Moonbit_array_length(buffer);
  int status = uv_get_process_title((char *)buffer, size);
  moonbit_decref(buffer);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_set_process_title(moonbit_bytes_t title) {
  int status = uv_set_process_title((const char *)title);
  moonbit_decref(title);
  return status;
}
