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

#include "mutex.h"

#include "uv.h"
#include <stdlib.h>

#if __STDC_VERSION__ >= 201112L
#include <stdatomic.h>
#endif

static inline void
moonbit_uv_mutex_finalize(void *object) {
  moonbit_uv_mutex_t *mutex = object;
  moonbit_uv_tracef("mutex = %p\n", (void *)mutex);
  moonbit_uv_tracef("mutex->block = %p\n", (void *)mutex->block);
  if (mutex->block) {
#if __STDC_VERSION__ >= 201112L
    int32_t arc = atomic_fetch_sub(&mutex->block->arc, 1);
    moonbit_uv_tracef("mutex->block->arc = %d -> %d\n", arc, arc - 1);
#else
    uv_mutex_lock(&mutex->block->mutex);
    int32_t arc = mutex->block->arc;
    moonbit_uv_tracef("mutex->block->arc = %d -> %d\n", arc, arc - 1);
    mutex->block->arc = arc - 1;
    uv_mutex_unlock(&mutex->block->mutex);
#endif
    if (arc > 1) {
      return;
    }
#if __STDC_VERSION__ >= 201112L
#else
    uv_mutex_destroy(&mutex->block->mutex);
#endif
    uv_mutex_destroy(&mutex->block->object);
    free(mutex->block);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_mutex_t *
moonbit_uv_mutex_make(void) {
  moonbit_uv_mutex_t *mutex =
    (moonbit_uv_mutex_t *)moonbit_make_external_object(
      moonbit_uv_mutex_finalize, sizeof(moonbit_uv_mutex_t)
    );
  memset(mutex, 0, sizeof(moonbit_uv_mutex_t));
  return mutex;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_mutex_init(moonbit_uv_mutex_t *mutex) {
  int status = 0;
  mutex->block = malloc(sizeof(*mutex->block));

#if __STDC_VERSION__ >= 201112L
  atomic_init(&mutex->block->arc, 1);
#else
  status = uv_mutex_init(&mutex->block->mutex);
  if (status < 0) {
    goto fail_to_init_mutex;
  }
  mutex->block->arc = 1;
#endif

  status = uv_mutex_init(&mutex->block->object);
  if (status < 0) {
    goto fail_to_init_object;
  }
  goto success;

fail_to_init_object:
#if __STDC_VERSION__ >= 201112L
#else
  uv_mutex_destroy(&mutex->block->mutex);
#endif
fail_to_init_mutex:
  free(mutex->block);
  mutex->block = NULL;
success:
  moonbit_decref(mutex);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_mutex_copy(moonbit_uv_mutex_t *self, moonbit_uv_mutex_t *other) {
#if __STDC_VERSION__ >= 201112L
  atomic_fetch_add(&self->block->arc, 1);
#else
  uv_mutex_lock(&self->block->mutex);
  self->block->arc += 1;
  uv_mutex_unlock(&self->block->mutex);
#endif
  other->block = self->block;
  moonbit_decref(self);
  moonbit_decref(other);
}

typedef struct moonbit_uv_mutex_lock_cb_s {
  int32_t (*code)(
    struct moonbit_uv_mutex_lock_cb_s *,
    moonbit_uv_mutex_t *mutex
  );
} moonbit_uv_mutex_lock_cb_t;

MOONBIT_FFI_EXPORT
void
moonbit_uv_mutex_lock(moonbit_uv_mutex_t *mutex) {
  uv_mutex_lock(&mutex->block->object);
  moonbit_decref(mutex);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_mutex_trylock(moonbit_uv_mutex_t *mutex) {
  int32_t status = uv_mutex_trylock(&mutex->block->object);
  moonbit_decref(mutex);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_mutex_unlock(moonbit_uv_mutex_t *mutex) {
  uv_mutex_unlock(&mutex->block->object);
  moonbit_decref(mutex);
}
