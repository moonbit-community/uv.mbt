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

#include "uv.h"

typedef struct moonbit_uv_key_s {
  uv_key_t key;
} moonbit_uv_key_t;

static inline void
moonbit_uv_key_finalize(void *object) {
  moonbit_uv_key_t *key = object;
  uv_key_delete(&key->key);
}

MOONBIT_FFI_EXPORT
moonbit_uv_key_t *
moonbit_uv_key_make(void) {
  moonbit_uv_key_t *key = (moonbit_uv_key_t *)moonbit_make_external_object(
    moonbit_uv_key_finalize, sizeof(moonbit_uv_key_t)
  );
  memset(key, 0, sizeof(moonbit_uv_key_t));
  return key;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_key_create(moonbit_uv_key_t *key) {
  int32_t status = uv_key_create(&key->key);
  moonbit_decref(key);
  return status;
}

MOONBIT_FFI_EXPORT
void *
moonbit_uv_key_get(moonbit_uv_key_t *key) {
  void *value = uv_key_get(&key->key);
  moonbit_decref(key);
  return value;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_key_set(moonbit_uv_key_t *key, void *value) {
  uv_key_set(&key->key, value);
  moonbit_decref(key);
}