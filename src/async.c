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

typedef struct moonbit_uv_async_s {
  uv_async_t async;
} moonbit_uv_async_t;

typedef struct moonbit_uv_async_cb {
  int32_t (*code)(struct moonbit_uv_async_cb *, moonbit_uv_async_t *);
} moonbit_uv_async_cb_t;

static inline void
moonbit_uv_async_finalize(void *object) {
  moonbit_uv_async_t *async = (moonbit_uv_async_t *)object;
  moonbit_uv_tracef("async = %p\n", (void *)async);
  moonbit_uv_tracef("async->rc = %d\n", Moonbit_object_header(async)->rc);
  if (async->async.loop) {
    moonbit_uv_tracef("async->async.loop = %p\n", (void *)async->async.loop);
    moonbit_uv_tracef(
      "async->async.loop->rc = %d\n",
      Moonbit_object_header(async->async.loop)->rc
    );
    moonbit_decref(async->async.loop);
    async->async.loop = NULL;
  }
  if (async->async.data) {
    moonbit_uv_tracef("async->async.data = %p\n", (void *)async->async.data);
    moonbit_uv_tracef(
      "async->async.data->rc = %d\n",
      Moonbit_object_header(async->async.data)->rc
    );
    moonbit_decref(async->async.data);
    async->async.data = NULL;
  }
}

static inline void
moonbit_uv_async_set_data(moonbit_uv_async_t *async, void *data) {
  if (async->async.data) {
    moonbit_decref(async->async.data);
  }
  async->async.data = data;
}

MOONBIT_FFI_EXPORT
moonbit_uv_async_t *
moonbit_uv_async_make(void) {
  moonbit_uv_async_t *async = moonbit_make_external_object(
    moonbit_uv_async_finalize, sizeof(moonbit_uv_async_t)
  );
  memset(async, 0, sizeof(moonbit_uv_async_t));
  moonbit_uv_tracef("async = %p\n", (void *)async);
  return async;
}

static inline void
moonbit_uv_async_cb(uv_async_t *async) {
  moonbit_uv_async_t *moonbit_async =
    containerof(async, moonbit_uv_async_t, async);
  moonbit_uv_tracef("moonbit_async = %p\n", (void *)moonbit_async);
  moonbit_uv_tracef(
    "moonbit_async->rc = %d\n", Moonbit_object_header(moonbit_async)->rc
  );
  moonbit_uv_async_cb_t *cb = moonbit_async->async.data;
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  moonbit_incref(cb);
  moonbit_incref(moonbit_async);
  cb->code(cb, moonbit_async);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_async_init(
  uv_loop_t *loop,
  moonbit_uv_async_t *async,
  moonbit_uv_async_cb_t *cb
) {
  moonbit_uv_async_set_data(async, cb);
  int status = uv_async_init(loop, &async->async, moonbit_uv_async_cb);
  moonbit_decref(async);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_async_send(moonbit_uv_async_t *async) {
  return uv_async_send(&async->async);
}
