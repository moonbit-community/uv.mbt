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

#ifndef MOONBIT_UV_STREAM_H
#define MOONBIT_UV_STREAM_H

#include "moonbit.h"
#include "uv#include#uv.h"

typedef struct moonbit_uv_alloc_cb_s {
  moonbit_bytes_t (*code)(
    struct moonbit_uv_alloc_cb_s *,
    uv_handle_t *handle,
    size_t suggested_size,
    int32_t *buf_offset,
    int32_t *buf_length
  );
} moonbit_uv_alloc_cb_t;

typedef struct moonbit_uv_connect_cb_s {
  int32_t (*code)(
    struct moonbit_uv_connect_cb_s *,
    uv_connect_t *req,
    int status
  );
} moonbit_uv_connect_cb_t;

static inline void
moonbit_uv_connect_cb(uv_connect_t *req, int status) {
  moonbit_uv_connect_cb_t *cb = req->data;
  cb->code(cb, req, status);
}

typedef struct moonbit_uv_connection_cb {
  int32_t (*code)(
    struct moonbit_uv_connection_cb *,
    uv_stream_t *server,
    int status
  );
} moonbit_uv_connection_cb_t;

#endif // MOONBIT_UV_STREAM_H
