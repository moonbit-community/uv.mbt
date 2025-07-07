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
#include "uv.h"

typedef struct moonbit_uv_fs_event_s {
  uv_fs_event_t fs_event;
} moonbit_uv_fs_event_t;

static inline void
moonbit_uv_fs_event_finalize(void *object) {
  moonbit_uv_fs_event_t *fs_event = (moonbit_uv_fs_event_t *)object;
  moonbit_uv_tracef("fs_event = %p\n", (void *)fs_event);
  if (fs_event->fs_event.data) {
    moonbit_decref(fs_event->fs_event.data);
    fs_event->fs_event.data = NULL;
  }
  if (fs_event->fs_event.loop) {
    moonbit_uv_tracef("fs_event->loop = %p\n", (void *)fs_event->fs_event.loop);
    moonbit_decref(fs_event->fs_event.loop);
    fs_event->fs_event.loop = NULL;
  }
}

static inline void
moonbit_uv_fs_event_set_data(moonbit_uv_fs_event_t *fs_event, void *data) {
  if (fs_event->fs_event.data) {
    moonbit_decref(fs_event->fs_event.data);
  }
  fs_event->fs_event.data = data;
}

MOONBIT_FFI_EXPORT
moonbit_uv_fs_event_t *
moonbit_uv_fs_event_make(void) {
  moonbit_uv_fs_event_t *fs_event = moonbit_make_external_object(
    moonbit_uv_fs_event_finalize, sizeof(moonbit_uv_fs_event_t)
  );
  memset(fs_event, 0, sizeof(moonbit_uv_fs_event_t));
  return fs_event;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_event_init(uv_loop_t *loop, moonbit_uv_fs_event_t *handle) {
  return uv_fs_event_init(loop, &handle->fs_event);
}

typedef struct moonbit_uv_fs_event_cb_s {
  int32_t (*code)(
    struct moonbit_uv_fs_event_cb_s *,
    moonbit_uv_fs_event_t *handle,
    const char *filename,
    int32_t events,
    int32_t status
  );
} moonbit_uv_fs_event_cb_t;

static inline void
moonbit_uv_fs_event_cb(
  uv_fs_event_t *fs_event,
  const char *filename,
  int32_t events,
  int32_t status
) {
  moonbit_uv_fs_event_t *moonbit_fs_event =
    containerof(fs_event, moonbit_uv_fs_event_t, fs_event);
  moonbit_uv_fs_event_cb_t *cb = moonbit_fs_event->fs_event.data;
  moonbit_incref(cb);
  moonbit_incref(moonbit_fs_event);
  cb->code(cb, moonbit_fs_event, filename, events, status);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_event_start(
  moonbit_uv_fs_event_t *handle,
  moonbit_uv_fs_event_cb_t *cb,
  moonbit_bytes_t path,
  int32_t flags
) {
  moonbit_uv_fs_event_set_data(handle, cb);
  int status = uv_fs_event_start(
    &handle->fs_event, moonbit_uv_fs_event_cb, (const char *)path, flags
  );
  moonbit_decref(handle);
  moonbit_decref(path);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_fs_event_stop(moonbit_uv_fs_event_t *handle) {
  int status = uv_fs_event_stop(&handle->fs_event);
  moonbit_decref(handle);
  return status;
}
