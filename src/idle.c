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

typedef struct moonbit_uv_idle_s {
  uv_idle_t idle;
} moonbit_uv_idle_t;

typedef struct moonbit_uv_idle_cb {
  int32_t (*code)(struct moonbit_uv_idle_cb *, moonbit_uv_idle_t *);
} moonbit_uv_idle_cb_t;

static inline void
moonbit_uv_idle_finalize(void *object) {
  moonbit_uv_idle_t *idle = (moonbit_uv_idle_t *)object;
  moonbit_uv_tracef("idle = %p\n", (void *)idle);
  moonbit_uv_tracef("idle->rc = %d\n", Moonbit_object_header(idle)->rc);
  if (idle->idle.loop) {
    moonbit_uv_tracef("idle->idle.loop = %p\n", (void *)idle->idle.loop);
    moonbit_uv_tracef(
      "idle->idle.loop->rc = %d\n", Moonbit_object_header(idle->idle.loop)->rc
    );
    moonbit_decref(idle->idle.loop);
    idle->idle.loop = NULL;
  }
  if (idle->idle.data) {
    moonbit_uv_tracef("idle->idle.data = %p\n", (void *)idle->idle.data);
    moonbit_uv_tracef(
      "idle->idle.data->rc = %d\n", Moonbit_object_header(idle->idle.data)->rc
    );
    moonbit_decref(idle->idle.data);
    idle->idle.data = NULL;
  }
}

static inline void
moonbit_uv_idle_set_data(moonbit_uv_idle_t *idle, void *data) {
  if (idle->idle.data) {
    moonbit_decref(idle->idle.data);
  }
  idle->idle.data = data;
}

MOONBIT_FFI_EXPORT
moonbit_uv_idle_t *
moonbit_uv_idle_make(void) {
  moonbit_uv_idle_t *idle = moonbit_make_external_object(
    moonbit_uv_idle_finalize, sizeof(moonbit_uv_idle_t)
  );
  memset(idle, 0, sizeof(moonbit_uv_idle_t));
  moonbit_uv_tracef("idle = %p\n", (void *)idle);
  return idle;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_idle_init(uv_loop_t *loop, moonbit_uv_idle_t *idle) {
  return uv_idle_init(loop, &idle->idle);
}

static inline void
moonbit_uv_idle_cb(uv_idle_t *idle) {
  moonbit_uv_idle_t *moonbit_idle = containerof(idle, moonbit_uv_idle_t, idle);
  moonbit_uv_tracef("moonbit_idle = %p\n", (void *)moonbit_idle);
  moonbit_uv_tracef(
    "moonbit_idle->rc = %d\n", Moonbit_object_header(moonbit_idle)->rc
  );
  moonbit_uv_idle_cb_t *cb = moonbit_idle->idle.data;
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  moonbit_incref(cb);
  moonbit_incref(moonbit_idle);
  cb->code(cb, moonbit_idle);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_idle_start(moonbit_uv_idle_t *idle, moonbit_uv_idle_cb_t *cb) {
  moonbit_uv_idle_set_data(idle, cb);
  int status = uv_idle_start(&idle->idle, moonbit_uv_idle_cb);
  moonbit_decref(idle);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_idle_stop(moonbit_uv_idle_t *idle) {
  moonbit_uv_tracef("idle = %p\n", (void *)idle);
  moonbit_uv_tracef("idle->rc = %d\n", Moonbit_object_header(idle)->rc);
  moonbit_uv_idle_set_data(idle, NULL);
  int status = uv_idle_stop(&idle->idle);
  moonbit_decref(idle);
  return status;
}
