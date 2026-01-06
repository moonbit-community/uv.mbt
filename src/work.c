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

#include "uv#include#uv.h"
#include "uv.h"

typedef struct moonbit_uv_work_cb_s {
  int32_t (*code)(struct moonbit_uv_work_cb_s *, uv_work_t *req);
} moonbit_uv_work_cb_t;

typedef struct moonbit_uv_after_work_cb_s {
  int32_t (*code)(
    struct moonbit_uv_after_work_cb_s *,
    uv_work_t *req,
    int status
  );
} moonbit_uv_after_work_cb_t;

typedef struct moonbit_uv_work_data_s {
  moonbit_uv_work_cb_t *work_cb;
  moonbit_uv_after_work_cb_t *after_cb;
} moonbit_uv_work_data_t;

static inline void
moonbit_uv_work_data_finalize(void *object) {
  moonbit_uv_work_data_t *data = object;
  if (data->work_cb) {
    moonbit_decref(data->work_cb);
  }
  if (data->after_cb) {
    moonbit_decref(data->after_cb);
  }
}

static inline moonbit_uv_work_data_t *
moonbit_uv_work_data_make(void) {
  moonbit_uv_work_data_t *data = moonbit_make_external_object(
    moonbit_uv_work_data_finalize, sizeof(moonbit_uv_work_data_t)
  );
  memset(data, 0, sizeof(moonbit_uv_work_data_t));
  return data;
}

static inline void
moonbit_uv_work_cb(uv_work_t *req) {
  moonbit_uv_work_data_t *data = req->data;
  moonbit_uv_work_cb_t *cb = data->work_cb;
  data->work_cb = NULL;
  moonbit_incref(req);
  cb->code(cb, req);
}

static inline void
moonbit_uv_after_work_cb(uv_work_t *req, int status) {
  moonbit_uv_work_data_t *data = req->data;
  moonbit_uv_after_work_cb_t *cb = data->after_cb;
  data->after_cb = NULL;
  cb->code(cb, req, status);
}

static inline void
moonbit_uv_work_finalize(void *object) {
  uv_work_t *work = object;
  if (work->loop) {
    moonbit_decref(work->loop);
  }
  if (work->data) {
    moonbit_decref(work->data);
  }
}

MOONBIT_FFI_EXPORT
uv_work_t *
moonbit_uv_work_make(void) {
  uv_work_t *work =
    moonbit_make_external_object(moonbit_uv_work_finalize, sizeof(uv_work_t));
  memset(work, 0, sizeof(uv_work_t));
  return work;
}

static inline void
moonbit_uv_req_set_data(uv_req_t *req, void *new_data) {
  void *old_data = uv_req_get_data(req);
  if (old_data) {
    moonbit_decref(old_data);
  }
  uv_req_set_data(req, new_data);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_queue_work(
  uv_loop_t *loop,
  uv_work_t *req,
  moonbit_uv_work_cb_t *work_cb,
  moonbit_uv_after_work_cb_t *after_cb
) {
  moonbit_uv_work_data_t *data = moonbit_uv_work_data_make();
  data->work_cb = work_cb;
  data->after_cb = after_cb;
  moonbit_uv_req_set_data((uv_req_t *)req, data);
  int status =
    uv_queue_work(loop, req, moonbit_uv_work_cb, moonbit_uv_after_work_cb);
  return status;
}
