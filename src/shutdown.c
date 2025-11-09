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

typedef struct moonbit_uv_shutdown_s {
  uv_shutdown_t shutdown;
} moonbit_uv_shutdown_t;

static inline void
moonbit_uv_shutdown_finalize(void *object) {
  moonbit_uv_shutdown_t *shutdown = object;
  if (shutdown->shutdown.data) {
    moonbit_decref(shutdown->shutdown.data);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_shutdown_t *
moonbit_uv_shutdown_make(void) {
  moonbit_uv_shutdown_t *shutdown =
    (moonbit_uv_shutdown_t *)moonbit_make_external_object(
      moonbit_uv_shutdown_finalize, sizeof(moonbit_uv_shutdown_t)
    );
  memset(shutdown, 0, sizeof(moonbit_uv_shutdown_t));
  return shutdown;
}

typedef struct moonbit_uv_shutdown_cb_s {
  int32_t (*code)(
    struct moonbit_uv_shutdown_cb_s *,
    moonbit_uv_shutdown_t *req,
    int status
  );
} moonbit_uv_shutdown_cb_t;

static inline void
moonbit_uv_shutdown_cb(uv_shutdown_t *req, int status) {
  moonbit_uv_shutdown_cb_t *cb = req->data;
  req->data = NULL;
  moonbit_uv_shutdown_t *shutdown =
    containerof(req, moonbit_uv_shutdown_t, shutdown);
  cb->code(cb, shutdown, status);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_shutdown(
  moonbit_uv_shutdown_t *req,
  uv_stream_t *handle,
  moonbit_uv_shutdown_cb_t *cb
) {
  if (req->shutdown.data) {
    moonbit_decref(req->shutdown.data);
  }
  req->shutdown.data = cb;
  int32_t status = uv_shutdown(&req->shutdown, handle, moonbit_uv_shutdown_cb);
  moonbit_decref(handle);
  return status;
}
