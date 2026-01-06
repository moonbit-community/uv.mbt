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
#include <stdlib.h>

typedef struct moonbit_uv_write_s {
  uv_write_t write;
} moonbit_uv_write_t;

static inline void
moonbit_uv_write_finalize(void *object) {
  moonbit_uv_write_t *write = object;
  if (write->write.data) {
    moonbit_decref(write->write.data);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_write_t *
moonbit_uv_write_make(void) {
  moonbit_uv_write_t *write =
    (moonbit_uv_write_t *)moonbit_make_external_object(
      moonbit_uv_write_finalize, sizeof(moonbit_uv_write_t)
    );
  memset(write, 0, sizeof(moonbit_uv_write_t));
  return write;
}

typedef struct moonbit_uv_write_cb {
  int32_t (*code)(
    struct moonbit_uv_write_cb *,
    moonbit_uv_write_t *req,
    int32_t status
  );
} moonbit_uv_write_cb_t;

typedef struct moonbit_uv_write_data_s {
  moonbit_uv_write_cb_t *cb;
  moonbit_bytes_t *bufs;
} moonbit_uv_write_data_t;

static inline void
moonbit_uv_write_cb(uv_write_t *req, int status) {
  moonbit_uv_write_data_t *data = req->data;
  moonbit_uv_write_cb_t *cb = data->cb;
  data->cb = NULL;
  moonbit_uv_write_t *write = containerof(req, moonbit_uv_write_t, write);
  cb->code(cb, write, status);
}

static inline void
moonbit_uv_write_data_finalize(void *object) {
  moonbit_uv_write_data_t *data = object;
  if (data->bufs) {
    moonbit_decref(data->bufs);
  }
  if (data->cb) {
    moonbit_decref(data->cb);
  }
}

static inline moonbit_uv_write_data_t *
moonbit_uv_write_data_make(void) {
  moonbit_uv_write_data_t *write_data =
    (moonbit_uv_write_data_t *)moonbit_make_external_object(
      moonbit_uv_write_data_finalize, sizeof(moonbit_uv_write_data_t)
    );
  memset(write_data, 0, sizeof(moonbit_uv_write_data_t));
  return write_data;
}

static inline void
moonbit_uv_write_set_data(
  moonbit_uv_write_t *req,
  moonbit_uv_write_data_t *data
) {
  if (req->write.data) {
    moonbit_decref(req->write.data);
  }
  req->write.data = data;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_write(
  moonbit_uv_write_t *req,
  uv_stream_t *handle,
  moonbit_bytes_t *bufs,
  int32_t *bufs_offset,
  int32_t *bufs_length,
  moonbit_uv_write_cb_t *cb
) {
  int bufs_size = Moonbit_array_length(bufs);
  uv_buf_t *bufs_data = malloc(sizeof(uv_buf_t) * bufs_size);
  for (int i = 0; i < bufs_size; i++) {
    bufs_data[i] =
      uv_buf_init((char *)bufs[i] + bufs_offset[i], bufs_length[i]);
  }
  moonbit_uv_write_data_t *data = moonbit_uv_write_data_make();
  data->bufs = bufs;
  data->cb = cb;
  moonbit_uv_write_set_data(req, data);
  int result =
    uv_write(&req->write, handle, bufs_data, bufs_size, moonbit_uv_write_cb);
  free(bufs_data);
  moonbit_decref(handle);
  moonbit_decref(bufs_offset);
  moonbit_decref(bufs_length);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_write2(
  moonbit_uv_write_t *req,
  uv_stream_t *handle,
  moonbit_bytes_t *bufs,
  int32_t *bufs_offset,
  int32_t *bufs_length,
  uv_stream_t *send_handle,
  moonbit_uv_write_cb_t *cb
) {
  int bufs_size = Moonbit_array_length(bufs);
  uv_buf_t *bufs_data = malloc(sizeof(uv_buf_t) * bufs_size);
  for (int i = 0; i < bufs_size; i++) {
    bufs_data[i] =
      uv_buf_init((char *)bufs[i] + bufs_offset[i], bufs_length[i]);
  }
  moonbit_uv_write_data_t *data = moonbit_uv_write_data_make();
  data->bufs = bufs;
  data->cb = cb;
  moonbit_uv_write_set_data(req, data);
  int result = uv_write2(
    &req->write, handle, bufs_data, bufs_size, send_handle, moonbit_uv_write_cb
  );
  free(bufs_data);
  moonbit_decref(handle);
  moonbit_decref(bufs_offset);
  moonbit_decref(bufs_length);
  moonbit_decref(send_handle);
  return result;
}
