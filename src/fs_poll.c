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

typedef struct moonbit_uv_fs_poll_s {
  uv_fs_poll_t fs_poll;
} moonbit_uv_fs_poll_t;

static inline void
moonbit_uv_fs_poll_finalize(void *object) {
  moonbit_uv_fs_poll_t *fs_poll = (moonbit_uv_fs_poll_t *)object;
  moonbit_uv_tracef("fs_poll = %p\n", (void *)fs_poll);
  if (fs_poll->fs_poll.data) {
    moonbit_decref(fs_poll->fs_poll.data);
    fs_poll->fs_poll.data = NULL;
  }
  if (fs_poll->fs_poll.loop) {
    moonbit_uv_tracef("fs_poll->loop = %p\n", (void *)fs_poll->fs_poll.loop);
    moonbit_decref(fs_poll->fs_poll.loop);
    fs_poll->fs_poll.loop = NULL;
  }
}

static inline void
moonbit_uv_fs_poll_set_data(moonbit_uv_fs_poll_t *fs_poll, void *data) {
  if (fs_poll->fs_poll.data) {
    moonbit_decref(fs_poll->fs_poll.data);
  }
  fs_poll->fs_poll.data = data;
}

MOONBIT_FFI_EXPORT
moonbit_uv_fs_poll_t *
moonbit_uv_fs_poll_make(void) {
  moonbit_uv_fs_poll_t *fs_poll = moonbit_make_external_object(
    moonbit_uv_fs_poll_finalize, sizeof(moonbit_uv_fs_poll_t)
  );
  memset(fs_poll, 0, sizeof(moonbit_uv_fs_poll_t));
  return fs_poll;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_poll_init(uv_loop_t *loop, moonbit_uv_fs_poll_t *handle) {
  return uv_fs_poll_init(loop, &handle->fs_poll);
}

typedef struct moonbit_uv_fs_poll_cb_s {
  int32_t (*code)(
    struct moonbit_uv_fs_poll_cb_s *,
    moonbit_uv_fs_poll_t *handle,
    int32_t status,
    moonbit_bytes_t prev,
    moonbit_bytes_t curr
  );
} moonbit_uv_fs_poll_cb_t;

static inline void
moonbit_uv_fs_poll_cb(
  uv_fs_poll_t *fs_poll,
  int32_t status,
  const uv_stat_t *prev,
  const uv_stat_t *curr
) {
  moonbit_uv_fs_poll_t *moonbit_fs_poll =
    containerof(fs_poll, moonbit_uv_fs_poll_t, fs_poll);
  moonbit_uv_fs_poll_cb_t *cb = moonbit_fs_poll->fs_poll.data;
  moonbit_incref(cb);
  moonbit_incref(moonbit_fs_poll);
  moonbit_bytes_t prev_stat = moonbit_make_bytes(sizeof(uv_stat_t), 0);
  memcpy(prev_stat, prev, sizeof(uv_stat_t));
  moonbit_bytes_t curr_stat = moonbit_make_bytes(sizeof(uv_stat_t), 0);
  memcpy(curr_stat, curr, sizeof(uv_stat_t));
  cb->code(cb, moonbit_fs_poll, status, prev_stat, curr_stat);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_poll_start(
  moonbit_uv_fs_poll_t *handle,
  moonbit_uv_fs_poll_cb_t *cb,
  moonbit_bytes_t path,
  uint32_t interval
) {
  moonbit_uv_fs_poll_set_data(handle, cb);
  int status = uv_fs_poll_start(
    &handle->fs_poll, moonbit_uv_fs_poll_cb, (const char *)path, interval
  );
  moonbit_decref(handle);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_poll_stop(moonbit_uv_fs_poll_t *handle) {
  int status = uv_fs_poll_stop(&handle->fs_poll);
  moonbit_decref(handle);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_poll_getpath(
  moonbit_uv_fs_poll_t *restrict handle,
  moonbit_bytes_t buffer,
  int32_t *restrict length
) {
  size_t uv_size = (size_t)*length;
  int status = uv_fs_poll_getpath(&handle->fs_poll, (char *)buffer, &uv_size);
  *length = (int32_t)uv_size;
  moonbit_decref(handle);
  moonbit_decref(buffer);
  moonbit_decref(length);
  return status;
}
