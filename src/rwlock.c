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
#include "uv.h"
#include <stdlib.h>

#if __STDC_VERSION__ >= 201112L
#include <stdatomic.h>
#endif

typedef struct moonbit_uv_rwlock_s {
#if __STDC_VERSION__ >= 201112L
  struct {
    _Atomic int32_t arc;
    uv_rwlock_t object;
  } *block;
#else
  struct {
    int32_t arc;
    uv_mutex_t mutex;
    uv_rwlock_t object;
  } *block;
#endif
} moonbit_uv_rwlock_t;

static inline void
moonbit_uv_rwlock_finalize(void *object) {
  moonbit_uv_rwlock_t *rwlock = object;
  moonbit_uv_tracef("rwlock = %p\n", (void *)rwlock);
  moonbit_uv_tracef("rwlock->block = %p\n", (void *)rwlock->block);
  if (rwlock->block) {
#if __STDC_VERSION__ >= 201112L
    int32_t arc = atomic_fetch_sub(&rwlock->block->arc, 1);
    moonbit_uv_tracef("rwlock->block->arc = %d -> %d\n", arc, arc - 1);
#else
    uv_mutex_lock(&rwlock->block->mutex);
    int32_t arc = rwlock->block->arc;
    moonbit_uv_tracef("rwlock->block->arc = %d -> %d\n", arc, arc - 1);
    rwlock->block->arc = arc - 1;
    uv_mutex_unlock(&rwlock->block->mutex);
#endif
    if (arc > 1) {
      return;
    }
#if __STDC_VERSION__ >= 201112L
#else
    uv_mutex_destroy(&rwlock->block->mutex);
#endif
    uv_rwlock_destroy(&rwlock->block->object);
    free(rwlock->block);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_rwlock_t *
moonbit_uv_rwlock_make(void) {
  moonbit_uv_rwlock_t *rwlock =
    (moonbit_uv_rwlock_t *)moonbit_make_external_object(
      moonbit_uv_rwlock_finalize, sizeof(moonbit_uv_rwlock_t)
    );
  memset(rwlock, 0, sizeof(moonbit_uv_rwlock_t));
  return rwlock;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rwlock_init(moonbit_uv_rwlock_t *rwlock) {
  int status = 0;
  rwlock->block = malloc(sizeof(*rwlock->block));

#if __STDC_VERSION__ >= 201112L
  atomic_init(&rwlock->block->arc, 1);
#else
  status = uv_mutex_init(&rwlock->block->mutex);
  if (status < 0) {
    goto fail_to_init_mutex;
  }
  rwlock->block->arc = 1;
#endif

  status = uv_rwlock_init(&rwlock->block->object);
  if (status < 0) {
    goto fail_to_init_object;
  }
  goto success;

fail_to_init_object:
#if __STDC_VERSION__ >= 201112L
#else
  uv_mutex_destroy(&rwlock->block->mutex);
#endif
fail_to_init_mutex:
  free(rwlock->block);
  rwlock->block = NULL;
success:
  moonbit_decref(rwlock);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_rwlock_copy(moonbit_uv_rwlock_t *self, moonbit_uv_rwlock_t *other) {
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
moonbit_uv_rwlock_rdlock(moonbit_uv_rwlock_t *rwlock) {
  uv_rwlock_rdlock(&rwlock->block->object);
  moonbit_decref(rwlock);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rwlock_tryrdlock(moonbit_uv_rwlock_t *rwlock) {
  int32_t status = uv_rwlock_tryrdlock(&rwlock->block->object);
  moonbit_decref(rwlock);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_rwlock_rdunlock(moonbit_uv_rwlock_t *rwlock) {
  uv_rwlock_rdunlock(&rwlock->block->object);
  moonbit_decref(rwlock);
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_rwlock_wrlock(moonbit_uv_rwlock_t *rwlock) {
  uv_rwlock_wrlock(&rwlock->block->object);
  moonbit_decref(rwlock);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_rwlock_trywrlock(moonbit_uv_rwlock_t *rwlock) {
  int32_t status = uv_rwlock_trywrlock(&rwlock->block->object);
  moonbit_decref(rwlock);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_rwlock_wrunlock(moonbit_uv_rwlock_t *rwlock) {
  uv_rwlock_wrunlock(&rwlock->block->object);
  moonbit_decref(rwlock);
}
