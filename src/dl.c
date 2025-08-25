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

typedef struct moonbit_uv_lib_s {
  uv_lib_t lib;
} moonbit_uv_lib_t;

static inline void
moonbit_uv_lib_finalize(void *object) {
  moonbit_uv_lib_t *lib = object;
  uv_dlclose(&lib->lib);
}

MOONBIT_FFI_EXPORT
moonbit_uv_lib_t *
moonbit_uv_lib_make(void) {
  moonbit_uv_lib_t *lib = (moonbit_uv_lib_t *)moonbit_make_external_object(
    moonbit_uv_lib_finalize, sizeof(moonbit_uv_lib_t)
  );
  memset(lib, 0, sizeof(moonbit_uv_lib_t));
  return lib;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_dlopen(moonbit_bytes_t filename, moonbit_uv_lib_t *lib) {
  int32_t status = uv_dlopen((const char *)filename, &lib->lib);
  moonbit_decref(filename);
  moonbit_decref(lib);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_dlsym(moonbit_uv_lib_t *lib, moonbit_bytes_t name, void **ptr) {
  int32_t status = uv_dlsym(&lib->lib, (const char *)name, ptr);
  moonbit_decref(lib);
  moonbit_decref(name);
  moonbit_decref(ptr);
  return status;
}

MOONBIT_FFI_EXPORT
const char *
moonbit_uv_dlerror(moonbit_uv_lib_t *lib) {
  const char *error = uv_dlerror(&lib->lib);
  moonbit_decref(lib);
  return error;
}
