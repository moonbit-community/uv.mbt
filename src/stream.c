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

#include "stream.h"

#include "handle.h"
#include "uv.h"

typedef struct moonbit_uv_read_cb {
  int32_t (*code)(
    struct moonbit_uv_read_cb *,
    uv_stream_t *stream,
    ssize_t nread,
    moonbit_bytes_t buf,
    int32_t buf_offset,
    int32_t buf_length
  );
} moonbit_uv_read_cb_t;

typedef struct moonbit_uv_stream_data_s {
  moonbit_bytes_t bytes;
  moonbit_uv_alloc_cb_t *alloc_cb;
  moonbit_uv_read_cb_t *read_cb;
} moonbit_uv_stream_data_t;

static inline void
moonbit_uv_stream_data_finalize(void *object) {
  moonbit_uv_tracef("object = %p\n", object);
  moonbit_uv_stream_data_t *data = object;
  if (data->bytes) {
    moonbit_decref(data->bytes);
  }
  if (data->read_cb) {
    moonbit_decref(data->read_cb);
  }
  if (data->alloc_cb) {
    moonbit_decref(data->alloc_cb);
  }
}

static inline moonbit_uv_stream_data_t *
moonbit_uv_stream_data_make(void) {
  moonbit_uv_stream_data_t *data =
    (moonbit_uv_stream_data_t *)moonbit_make_external_object(
      moonbit_uv_stream_data_finalize, sizeof(moonbit_uv_stream_data_t)
    );
  memset(data, 0, sizeof(moonbit_uv_stream_data_t));
  moonbit_uv_tracef("data = %p\n", (void *)data);
  return data;
}

static inline void
moonbit_uv_read_start_alloc_cb(
  uv_handle_t *handle,
  size_t suggested_size,
  uv_buf_t *buf
) {
  moonbit_uv_stream_data_t *stream_data = handle->data;
  handle->data = NULL;
  moonbit_uv_alloc_cb_t *alloc_cb = stream_data->alloc_cb;
  int32_t buf_offset = 0;
  int32_t buf_length = 0;
  moonbit_incref(alloc_cb);
  moonbit_incref(handle);
  moonbit_uv_tracef("handle = %p\n", (void *)handle);
  moonbit_uv_tracef("handle->rc = %d\n", Moonbit_object_header(handle)->rc);
  moonbit_bytes_t buf_base =
    alloc_cb->code(alloc_cb, handle, suggested_size, &buf_offset, &buf_length);
  moonbit_uv_tracef("handle = %p\n", (void *)handle);
  moonbit_uv_tracef("handle->rc = %d\n", Moonbit_object_header(handle)->rc);
  moonbit_uv_tracef("handle->data = %p\n", handle->data);
  moonbit_uv_tracef("buf_base = %p\n", (void *)buf_base);
  buf->base = (char *)buf_base + buf_offset;
  buf->len = buf_length;
  stream_data->bytes = buf_base;
  moonbit_uv_handle_set_data(handle, stream_data);
}

static inline void
moonbit_uv_read_start_read_cb(
  uv_stream_t *stream,
  ssize_t nread,
  const uv_buf_t *buf
) {
  moonbit_uv_tracef("stream = %p\n", (void *)stream);
  moonbit_uv_stream_data_t *stream_data = stream->data;
  moonbit_uv_read_cb_t *read_cb = stream_data->read_cb;
  moonbit_bytes_t buf_base = stream_data->bytes;
  stream_data->bytes = NULL;
  int32_t buf_offset = buf->base - (char *)buf_base;
  int32_t buf_length = buf->len;
  moonbit_incref(read_cb);
  moonbit_incref(stream);
  moonbit_uv_tracef(
    "stream->rc (before) = %d\n", Moonbit_object_header(stream)->rc
  );
  read_cb->code(read_cb, stream, nread, buf_base, buf_offset, buf_length);
  moonbit_uv_tracef(
    "stream->rc (after ) = %d\n", Moonbit_object_header(stream)->rc
  );
}

static inline void
moonbit_uv_stream_set_data(
  uv_stream_t *stream,
  moonbit_uv_stream_data_t *data
) {
  if (stream->data) {
    moonbit_decref(stream->data);
  }
  stream->data = data;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_read_start(
  uv_stream_t *stream,
  moonbit_uv_alloc_cb_t *alloc_cb,
  moonbit_uv_read_cb_t *read_cb
) {
  moonbit_uv_tracef("stream = %p\n", (void *)stream);
  moonbit_uv_tracef("stream->rc = %d\n", Moonbit_object_header(stream)->rc);
  moonbit_uv_stream_data_t *data = moonbit_uv_stream_data_make();
  data->read_cb = read_cb;
  data->alloc_cb = alloc_cb;
  moonbit_uv_stream_set_data(stream, data);
  // Move `stream` into `loop`. This helps `stream` remains valid when
  // `alloc_cb` or `read_cb` is called.
  int32_t status = uv_read_start(
    stream, moonbit_uv_read_start_alloc_cb, moonbit_uv_read_start_read_cb
  );
  moonbit_decref(stream);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_read_stop(uv_stream_t *stream) {
  moonbit_uv_tracef("stream = %p\n", (void *)stream);
  moonbit_uv_tracef("stream->rc = %d\n", Moonbit_object_header(stream)->rc);
  moonbit_uv_stream_set_data(stream, NULL);
  int32_t status = uv_read_stop(stream);
  moonbit_decref(stream);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_is_readable(uv_stream_t *stream) {
  return uv_is_readable(stream);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_is_writable(uv_stream_t *stream) {
  return uv_is_writable(stream);
}

MOONBIT_FFI_EXPORT
uv_connect_t *
moonbit_uv_connect_make(void) {
  uv_connect_t *connect =
    (uv_connect_t *)moonbit_make_bytes(sizeof(uv_connect_t), 0);
  return connect;
}

static inline void
moonbit_uv_listen_cb(uv_stream_t *server, int status) {
  moonbit_uv_connection_cb_t *cb = server->data;
  moonbit_incref(cb);
  moonbit_incref(server);
  cb->code(cb, server, status);
  moonbit_uv_tracef("server->rc = %d\n", Moonbit_object_header(server)->rc);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_listen(
  uv_stream_t *stream,
  int32_t backlog,
  moonbit_uv_connection_cb_t *cb
) {
  moonbit_uv_tracef("stream = %p\n", (void *)stream);
  moonbit_uv_tracef("stream->rc = %d\n", Moonbit_object_header(stream)->rc);
  stream->data = cb;
  int result = uv_listen(stream, backlog, moonbit_uv_listen_cb);
  moonbit_decref(stream);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_accept(uv_stream_t *server, uv_stream_t *client) {
  int status = uv_accept(server, client);
  moonbit_decref(server);
  moonbit_decref(client);
  return status;
}
