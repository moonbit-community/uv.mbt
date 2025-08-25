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

typedef struct moonbit_uv_barrier_s {
  uv_barrier_t barrier;
} moonbit_uv_barrier_t;

static inline void
moonbit_uv_barrier_finalize(void *object) {
  moonbit_uv_barrier_t *barrier = object;
  uv_barrier_destroy(&barrier->barrier);
}

MOONBIT_FFI_EXPORT
moonbit_uv_barrier_t *
moonbit_uv_barrier_make(void) {
  moonbit_uv_barrier_t *barrier =
    (moonbit_uv_barrier_t *)moonbit_make_external_object(
      moonbit_uv_barrier_finalize, sizeof(moonbit_uv_barrier_t)
    );
  memset(barrier, 0, sizeof(moonbit_uv_barrier_t));
  return barrier;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_barrier_init(moonbit_uv_barrier_t *barrier, uint32_t count) {
  int32_t status = uv_barrier_init(&barrier->barrier, count);
  moonbit_decref(barrier);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_barrier_wait(moonbit_uv_barrier_t *barrier) {
  int32_t status = uv_barrier_wait(&barrier->barrier);
  moonbit_decref(barrier);
  return status;
}
