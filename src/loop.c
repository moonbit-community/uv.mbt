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

MOONBIT_FFI_EXPORT
uv_loop_t *
moonbit_uv_loop_make(void) {
  uv_loop_t *loop = (uv_loop_t *)moonbit_make_bytes(sizeof(uv_loop_t), 0);
  memset(loop, 0, sizeof(uv_loop_t));
  return loop;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_loop_init(uv_loop_t *loop) {
  int result = uv_loop_init(loop);
  moonbit_decref(loop);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_loop_configure_block_signal(uv_loop_t *loop, int32_t signum) {
  int result = uv_loop_configure(loop, UV_LOOP_BLOCK_SIGNAL, signum);
  moonbit_decref(loop);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_loop_configure(uv_loop_t *loop, int32_t option) {
  int result = uv_loop_configure(loop, option);
  moonbit_decref(loop);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_loop_close(uv_loop_t *loop) {
  int result = uv_loop_close(loop);
  moonbit_decref(loop);
  return result;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_stop(uv_loop_t *loop) {
  uv_stop(loop);
  moonbit_decref(loop);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_run(uv_loop_t *loop, uv_run_mode mode) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("loop->rc = %d\n", Moonbit_object_header(loop)->rc);
  int status = uv_run(loop, mode);
  moonbit_decref(loop);
  return status;
}

typedef struct moonbit_uv_walk_cb_s {
  int32_t (*code)(struct moonbit_uv_walk_cb_s *, uv_handle_t *);
} moonbit_uv_walk_cb_t;

static inline void
moonbit_uv_walk_cb(uv_handle_t *handle, void *arg) {
  moonbit_uv_tracef("handle = %p\n", (void *)handle);
  moonbit_uv_tracef("handle->rc = %d\n", Moonbit_object_header(handle)->rc);
  moonbit_uv_walk_cb_t *cb = arg;
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  moonbit_incref(cb);
  moonbit_incref(handle);
  cb->code(cb, handle);
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_walk(uv_loop_t *loop, void *walk_cb) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("loop->rc = %d\n", Moonbit_object_header(loop)->rc);
  moonbit_uv_tracef("walk_cb = %p\n", walk_cb);
  moonbit_uv_tracef("walk_cb->rc = %d\n", Moonbit_object_header(walk_cb)->rc);
  uv_walk(loop, moonbit_uv_walk_cb, walk_cb);
  moonbit_decref(loop);
  moonbit_decref(walk_cb);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_loop_alive(uv_loop_t *loop) {
  int alive = uv_loop_alive(loop);
  moonbit_decref(loop);
  return alive;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_now(uv_loop_t *loop) {
  uint64_t now = uv_now(loop);
  moonbit_decref(loop);
  return now;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_update_time(uv_loop_t *loop) {
  uv_update_time(loop);
  moonbit_decref(loop);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_print_all_handles(uv_loop_t *loop, int fd) {
  FILE *stream = fdopen(fd, "w");
  moonbit_uv_tracef("stream: %p\n", (void *)stream);
  if (!stream) {
    return uv_translate_sys_error(errno);
  }
  uv_print_all_handles(loop, stream);
  moonbit_decref(loop);
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_backend_fd(uv_loop_t *loop) {
  int fd = uv_backend_fd(loop);
  moonbit_decref(loop);
  return fd;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_backend_timeout(uv_loop_t *loop) {
  uint64_t timeout = uv_backend_timeout(loop);
  moonbit_decref(loop);
  return timeout;
}
