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
#include "uv.h"

typedef struct moonbit_uv_os_environ_s {
  uv_env_item_t *items;
  int32_t count;
} moonbit_uv_environ_t;

static inline void
moonbit_uv_environ_finalize(void *object) {
  moonbit_uv_environ_t *env = object;
  if (env->items) {
    uv_os_free_environ(env->items, env->count);
    env->items = NULL;
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_environ_t *
moonbit_uv_environ_make() {
  moonbit_uv_environ_t *env =
    (moonbit_uv_environ_t *)moonbit_make_external_object(
      moonbit_uv_environ_finalize, sizeof(moonbit_uv_environ_t)
    );
  env->items = NULL;
  env->count = 0;
  return env;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_environ_count(moonbit_uv_environ_t *env) {
  return env->count;
}

MOONBIT_FFI_EXPORT
const char *
moonbit_uv_environ_get_name(moonbit_uv_environ_t *env, int32_t index) {
  return env->items[index].name;
}

MOONBIT_FFI_EXPORT
const char *
moonbit_uv_environ_get_value(moonbit_uv_environ_t *env, int32_t index) {
  return env->items[index].value;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_environ(moonbit_uv_environ_t *env) {
  if (env->items) {
    moonbit_uv_environ_finalize(env);
  }
  int status = uv_os_environ(&env->items, &env->count);
  moonbit_decref(env);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_getenv(
  moonbit_bytes_t name,
  moonbit_bytes_t bytes,
  int32_t *size
) {
  size_t size_value = *size;
  int32_t status = uv_os_getenv((const char *)name, (char *)bytes, &size_value);
  *size = size_value;
  moonbit_decref(name);
  moonbit_decref(bytes);
  moonbit_decref(size);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_setenv(moonbit_bytes_t name, moonbit_bytes_t value) {
  int32_t status = uv_os_setenv((const char *)name, (const char *)value);
  moonbit_decref(name);
  moonbit_decref(value);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_os_unsetenv(moonbit_bytes_t name) {
  int32_t status = uv_os_unsetenv((const char *)name);
  moonbit_decref(name);
  return status;
}
