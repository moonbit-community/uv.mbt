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

#include "stream.h"
#include "uv.h"
#include <string.h>

typedef struct moonbit_uv_pipe_s {
  uv_pipe_t pipe;
} moonbit_uv_pipe_t;

static inline void
moonbit_uv_pipe_finalize(void *object) {
  moonbit_uv_pipe_t *pipe = (moonbit_uv_pipe_t *)object;
  if (pipe->pipe.data) {
    moonbit_decref(pipe->pipe.data);
    pipe->pipe.data = NULL;
  }
  if (pipe->pipe.loop) {
    moonbit_decref(pipe->pipe.loop);
    pipe->pipe.loop = NULL;
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_pipe_t *
moonbit_uv_pipe_make(void) {
  moonbit_uv_pipe_t *pipe = moonbit_make_external_object(
    moonbit_uv_pipe_finalize, sizeof(moonbit_uv_pipe_t)
  );
  memset(pipe, 0, sizeof(moonbit_uv_pipe_t));
  moonbit_uv_tracef("pipe = %p\n", (void *)pipe);
  return pipe;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_pipe_init(uv_loop_t *loop, moonbit_uv_pipe_t *handle, int32_t ipc) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("loop->rc = %d\n", Moonbit_object_header(loop)->rc);
  moonbit_uv_tracef("pipe = %p\n", (void *)handle);
  moonbit_uv_tracef("pipe->rc = %d\n", Moonbit_object_header(handle)->rc);
  return uv_pipe_init(loop, &handle->pipe, ipc);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_pipe_open(moonbit_uv_pipe_t *handle, int32_t fd) {
  int result = uv_pipe_open(&handle->pipe, fd);
  moonbit_decref(handle);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_pipe_bind(
  moonbit_uv_pipe_t *handle,
  moonbit_bytes_t name,
  uint32_t flags
) {
  size_t name_length = Moonbit_array_length(name);
  int result =
    uv_pipe_bind2(&handle->pipe, (const char *)name, name_length, flags);
  moonbit_decref(handle);
  moonbit_decref(name);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_pipe(int32_t *fds, int32_t read_flags, int32_t write_flags) {
  int status = uv_pipe(fds, read_flags, write_flags);
  moonbit_decref(fds);
  return status;
}

MOONBIT_FFI_EXPORT
uint32_t
moonbit_uv_pipe_pending_count(uv_pipe_t *handle) {
  uint32_t count = uv_pipe_pending_count(handle);
  moonbit_decref(handle);
  return count;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_pipe_pending_type(uv_pipe_t *handle) {
  uv_handle_type type = uv_pipe_pending_type(handle);
  moonbit_decref(handle);
  return (int32_t)type;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_pipe_connect2(
  uv_connect_t *req,
  moonbit_uv_pipe_t *handle,
  moonbit_bytes_t name,
  uint32_t flags,
  moonbit_uv_connection_cb_t *cb
) {
  if (req->data) {
    moonbit_decref(req->data);
  }
  req->data = cb;
  size_t name_length = Moonbit_array_length(name);
  int result = uv_pipe_connect2(
    req, &handle->pipe, (const char *)name, name_length, flags,
    moonbit_uv_connect_cb
  );
  moonbit_decref(handle);
  moonbit_decref(name);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_pipe_chmod(moonbit_uv_pipe_t *handle, int flags) {
  int result = uv_pipe_chmod(&handle->pipe, flags);
  moonbit_decref(handle);
  return result;
}
