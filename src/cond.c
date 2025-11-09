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

#include "mutex.h"
#include "uv#include#uv.h"
#include "uv.h"
#include <stdlib.h>

#if __STDC_VERSION__ >= 201112L
#include <stdatomic.h>
#endif

typedef struct moonbit_uv_cond_s {
#if __STDC_VERSION__ >= 201112L
  struct {
    _Atomic int32_t arc;
    uv_cond_t object;
  } *block;
#else
  struct {
    int32_t arc;
    uv_mutex_t mutex;
    uv_cond_t object;
  } *block;
#endif
} moonbit_uv_cond_t;

static inline void
moonbit_uv_cond_finalize(void *object) {
  moonbit_uv_cond_t *cond = object;
  moonbit_uv_tracef("cond = %p\n", (void *)cond);
  moonbit_uv_tracef("cond->block = %p\n", (void *)cond->block);
  if (cond->block) {
#if __STDC_VERSION__ >= 201112L
    int32_t arc = atomic_fetch_sub(&cond->block->arc, 1);
    moonbit_uv_tracef("cond->block->arc = %d -> %d\n", arc, arc - 1);
#else
    uv_mutex_lock(&cond->block->mutex);
    int32_t arc = cond->block->arc;
    moonbit_uv_tracef("cond->block->arc = %d -> %d\n", arc, arc - 1);
    cond->block->arc = arc - 1;
    uv_mutex_unlock(&cond->block->mutex);
#endif
    if (arc > 1) {
      return;
    }
#if __STDC_VERSION__ >= 201112L
#else
    uv_mutex_destroy(&cond->block->mutex);
#endif
    uv_cond_destroy(&cond->block->object);
    free(cond->block);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_cond_t *
moonbit_uv_cond_make(void) {
  moonbit_uv_cond_t *cond = (moonbit_uv_cond_t *)moonbit_make_external_object(
    moonbit_uv_cond_finalize, sizeof(moonbit_uv_cond_t)
  );
  memset(cond, 0, sizeof(moonbit_uv_cond_t));
  return cond;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_cond_init(moonbit_uv_cond_t *cond) {
  int status = 0;
  cond->block = malloc(sizeof(*cond->block));

#if __STDC_VERSION__ >= 201112L
  atomic_init(&cond->block->arc, 1);
#else
  status = uv_mutex_init(&cond->block->mutex);
  if (status < 0) {
    goto fail_to_init_mutex;
  }
  cond->block->arc = 1;
#endif

  status = uv_cond_init(&cond->block->object);
  if (status < 0) {
    goto fail_to_init_object;
  }
  goto success;

fail_to_init_object:
#if __STDC_VERSION__ >= 201112L
#else
  uv_mutex_destroy(&cond->block->mutex);
#endif
fail_to_init_mutex:
  free(cond->block);
  cond->block = NULL;
success:
  moonbit_decref(cond);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_cond_copy(moonbit_uv_cond_t *self, moonbit_uv_cond_t *other) {
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

MOONBIT_FFI_EXPORT
void
moonbit_uv_cond_signal(moonbit_uv_cond_t *cond) {
  uv_cond_signal(&cond->block->object);
  moonbit_decref(cond);
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_cond_broadcast(moonbit_uv_cond_t *cond) {
  uv_cond_broadcast(&cond->block->object);
  moonbit_decref(cond);
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_cond_wait(moonbit_uv_cond_t *cond, moonbit_uv_mutex_t *mutex) {
  uv_cond_wait(&cond->block->object, &mutex->block->object);
  moonbit_decref(cond);
  moonbit_decref(mutex);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_cond_timedwait(
  moonbit_uv_cond_t *cond,
  moonbit_uv_mutex_t *mutex,
  uint64_t timeout
) {
  int32_t status =
    uv_cond_timedwait(&cond->block->object, &mutex->block->object, timeout);
  moonbit_decref(cond);
  moonbit_decref(mutex);
  return status;
}
