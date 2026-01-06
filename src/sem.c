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

typedef struct moonbit_uv_sem_s {
#if __STDC_VERSION__ >= 201112L
  struct {
    _Atomic int32_t arc;
    uv_sem_t object;
  } *block;
#else
  struct {
    int32_t arc;
    uv_mutex_t mutex;
    uv_sem_t object;
  } *block;
#endif
} moonbit_uv_sem_t;

static inline void
moonbit_uv_sem_finalize(void *object) {
  moonbit_uv_sem_t *sem = object;
  moonbit_uv_tracef("sem = %p\n", (void *)sem);
  moonbit_uv_tracef("sem->block = %p\n", (void *)sem->block);
  if (sem->block) {
#if __STDC_VERSION__ >= 201112L
    int32_t arc = atomic_fetch_sub(&sem->block->arc, 1);
    moonbit_uv_tracef("sem->block->arc = %d -> %d\n", arc, arc - 1);
#else
    uv_mutex_lock(&sem->block->mutex);
    int32_t arc = sem->block->arc;
    moonbit_uv_tracef("sem->block->arc = %d -> %d\n", arc, arc - 1);
    sem->block->arc = arc - 1;
    uv_mutex_unlock(&sem->block->mutex);
#endif
    if (arc > 1) {
      return;
    }
#if __STDC_VERSION__ >= 201112L
#else
    uv_mutex_destroy(&sem->block->mutex);
#endif
    uv_sem_destroy(&sem->block->object);
    free(sem->block);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_sem_t *
moonbit_uv_sem_make(void) {
  moonbit_uv_sem_t *sem = (moonbit_uv_sem_t *)moonbit_make_external_object(
    moonbit_uv_sem_finalize, sizeof(moonbit_uv_sem_t)
  );
  memset(sem, 0, sizeof(moonbit_uv_sem_t));
  return sem;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_sem_init(moonbit_uv_sem_t *sem, uint32_t value) {
  int status = 0;
  sem->block = malloc(sizeof(*sem->block));

#if __STDC_VERSION__ >= 201112L
  atomic_init(&sem->block->arc, 1);
#else
  status = uv_mutex_init(&sem->block->mutex);
  if (status < 0) {
    goto fail_to_init_mutex;
  }
  sem->block->arc = 1;
#endif

  status = uv_sem_init(&sem->block->object, value);
  if (status < 0) {
    goto fail_to_init_object;
  }
  goto success;

fail_to_init_object:
#if __STDC_VERSION__ >= 201112L
#else
  uv_mutex_destroy(&sem->block->mutex);
#endif
fail_to_init_mutex:
  free(sem->block);
  sem->block = NULL;
success:
  moonbit_decref(sem);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_sem_copy(moonbit_uv_sem_t *self, moonbit_uv_sem_t *other) {
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
moonbit_uv_sem_post(moonbit_uv_sem_t *sem) {
  uv_sem_post(&sem->block->object);
  moonbit_decref(sem);
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_sem_wait(moonbit_uv_sem_t *sem) {
  uv_sem_wait(&sem->block->object);
  moonbit_decref(sem);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_sem_trywait(moonbit_uv_sem_t *sem) {
  int32_t status = uv_sem_trywait(&sem->block->object);
  moonbit_decref(sem);
  return status;
}
