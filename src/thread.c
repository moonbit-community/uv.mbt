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

typedef struct moonbit_uv_thread_s {
  struct {
    int32_t arc;
    uv_mutex_t mutex;
    uv_thread_t object;
  } *block;
} moonbit_uv_thread_t;

static inline void
moonbit_uv_thread_finalize(void *object) {
  moonbit_uv_thread_t *thread = object;
  if (thread->block) {
    uv_mutex_lock(&thread->block->mutex);
    int32_t arc = thread->block->arc;
    thread->block->arc = arc - 1;
    uv_mutex_unlock(&thread->block->mutex);
    if (arc > 1) {
      return;
    }
    uv_mutex_destroy(&thread->block->mutex);
    free(thread->block);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_thread_t *
moonbit_uv_thread_make(void) {
  moonbit_uv_thread_t *thread =
    (moonbit_uv_thread_t *)moonbit_make_external_object(
      moonbit_uv_thread_finalize, sizeof(moonbit_uv_thread_t)
    );
  memset(thread, 0, sizeof(moonbit_uv_thread_t));
  return thread;
}

typedef struct moonbit_uv_thread_cb_s {
  int32_t (*code)(struct moonbit_uv_thread_cb_s *);
} moonbit_uv_thread_cb_t;

static inline void
moonbit_uv_thread_cb(void *arg) {
  moonbit_uv_thread_cb_t *cb = arg;
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  cb->code(cb);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_create(
  moonbit_uv_thread_t *thread,
  moonbit_uv_thread_cb_t *cb
) {
  thread->block = malloc(sizeof(*thread->block));
  int status = uv_mutex_init(&thread->block->mutex);
  if (status < 0) {
    moonbit_decref(cb);
    goto fail_to_init_mutex;
  }
  thread->block->arc = 1;
  status = uv_thread_create(&thread->block->object, moonbit_uv_thread_cb, cb);
  if (status < 0) {
    moonbit_decref(cb);
    goto fail_to_init_object;
  }
  goto success;

fail_to_init_object:
  uv_mutex_destroy(&thread->block->mutex);
fail_to_init_mutex:
  free(thread->block);
  thread->block = NULL;
success:
  moonbit_decref(thread);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_join(moonbit_uv_thread_t *thread) {
  int32_t status = uv_thread_join(&thread->block->object);
  moonbit_decref(thread);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_equal(moonbit_uv_thread_t *t1, moonbit_uv_thread_t *t2) {
  int equality = uv_thread_equal(&t1->block->object, &t2->block->object);
  moonbit_decref(t1);
  moonbit_decref(t2);
  return equality;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_self(moonbit_uv_thread_t *thread) {
  thread->block = malloc(sizeof(*thread->block));
  thread->block->arc = 1;
  int32_t status = uv_mutex_init(&thread->block->mutex);
  thread->block->object = uv_thread_self();
  moonbit_decref(thread);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_thread_copy(moonbit_uv_thread_t *self, moonbit_uv_thread_t *other) {
  uv_mutex_lock(&self->block->mutex);
  self->block->arc += 1;
  uv_mutex_unlock(&self->block->mutex);
  other->block = self->block;
  moonbit_decref(self);
  moonbit_decref(other);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_cpumask_size(void) {
  return uv_cpumask_size();
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_getcpu(void) {
  return uv_thread_getcpu();
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_setaffinity(
  moonbit_uv_thread_t *thread,
  void *cpumask,
  void *oldmask,
  int32_t mask_size
) {
  int32_t status = uv_thread_setaffinity(
    &thread->block->object, (char *)cpumask, (char *)oldmask, (size_t)mask_size
  );
  moonbit_decref(thread);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_getaffinity(
  moonbit_uv_thread_t *thread,
  void *cpumask,
  int32_t mask_size
) {
  int32_t status = uv_thread_getaffinity(
    &thread->block->object, (char *)cpumask, (size_t)mask_size
  );
  moonbit_decref(thread);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_detach(moonbit_uv_thread_t *thread) {
  int32_t status = uv_thread_detach(&thread->block->object);
  moonbit_decref(thread);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_setname(moonbit_bytes_t name) {
  int32_t status = uv_thread_setname((const char *)name);
  moonbit_decref(name);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_getname(
  moonbit_uv_thread_t *thread,
  void *name,
  int32_t size
) {
  int32_t status =
    uv_thread_getname(&thread->block->object, (char *)name, (size_t)size);
  moonbit_decref(thread);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_setpriority(moonbit_uv_thread_t *thread, int32_t priority) {
  int32_t status = uv_thread_setpriority(thread->block->object, priority);
  moonbit_decref(thread);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_thread_getpriority(moonbit_uv_thread_t *thread, int32_t *priority) {
  int32_t status = uv_thread_getpriority(thread->block->object, priority);
  moonbit_decref(thread);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_THREAD_PRIORITY_HIGHEST(void) {
  return UV_THREAD_PRIORITY_HIGHEST;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_THREAD_PRIORITY_ABOVE_NORMAL(void) {
  return UV_THREAD_PRIORITY_ABOVE_NORMAL;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_THREAD_PRIORITY_NORMAL(void) {
  return UV_THREAD_PRIORITY_NORMAL;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_THREAD_PRIORITY_BELOW_NORMAL(void) {
  return UV_THREAD_PRIORITY_BELOW_NORMAL;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_THREAD_PRIORITY_LOWEST(void) {
  return UV_THREAD_PRIORITY_LOWEST;
}
