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
#include "socket.h"
#include "uv#include#uv.h"
#include "uv.h"
#include <string.h>

typedef struct moonbit_uv_poll_s {
  uv_poll_t poll;
} moonbit_uv_poll_t;

typedef struct moonbit_uv_poll_cb {
  int32_t (*code)(
    struct moonbit_uv_poll_cb *,
    moonbit_uv_poll_t *,
    int32_t,
    int32_t
  );
} moonbit_uv_poll_cb_t;

static inline void
moonbit_uv_poll_finalize(void *object) {
  moonbit_uv_poll_t *poll = (moonbit_uv_poll_t *)object;
  moonbit_uv_tracef("poll = %p\n", (void *)poll);
  moonbit_uv_tracef("poll->rc = %d\n", Moonbit_object_header(poll)->rc);
  if (poll->poll.loop) {
    moonbit_uv_tracef("poll->poll.loop = %p\n", (void *)poll->poll.loop);
    moonbit_uv_tracef(
      "poll->poll.loop->rc = %d\n", Moonbit_object_header(poll->poll.loop)->rc
    );
    moonbit_decref(poll->poll.loop);
    poll->poll.loop = NULL;
  }
  if (poll->poll.data) {
    moonbit_uv_tracef("poll->poll.data = %p\n", (void *)poll->poll.data);
    moonbit_uv_tracef(
      "poll->poll.data->rc = %d\n", Moonbit_object_header(poll->poll.data)->rc
    );
    moonbit_decref(poll->poll.data);
    poll->poll.data = NULL;
  }
}

static inline void
moonbit_uv_poll_set_data(moonbit_uv_poll_t *poll, void *data) {
  if (poll->poll.data) {
    moonbit_decref(poll->poll.data);
  }
  poll->poll.data = data;
}

MOONBIT_FFI_EXPORT
moonbit_uv_poll_t *
moonbit_uv_poll_make(void) {
  moonbit_uv_poll_t *poll = moonbit_make_external_object(
    moonbit_uv_poll_finalize, sizeof(moonbit_uv_poll_t)
  );
  memset(poll, 0, sizeof(moonbit_uv_poll_t));
  moonbit_uv_tracef("poll = %p\n", (void *)poll);
  return poll;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_poll_init(uv_loop_t *loop, moonbit_uv_poll_t *poll, int32_t fd) {
  return uv_poll_init(loop, &poll->poll, fd);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_poll_init_socket(
  uv_loop_t *loop,
  moonbit_uv_poll_t *poll,
  moonbit_uv_os_sock_t *os_sock
) {
  int32_t result = uv_poll_init_socket(loop, &poll->poll, os_sock->sock);
  moonbit_decref(os_sock);
  return result;
}

static inline void
moonbit_uv_poll_cb(uv_poll_t *poll, int status, int events) {
  moonbit_uv_poll_t *moonbit_poll = containerof(poll, moonbit_uv_poll_t, poll);
  moonbit_uv_tracef("moonbit_poll = %p\n", (void *)moonbit_poll);
  moonbit_uv_tracef(
    "moonbit_poll->rc = %d\n", Moonbit_object_header(moonbit_poll)->rc
  );
  moonbit_uv_poll_cb_t *cb = moonbit_poll->poll.data;
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  moonbit_incref(cb);
  moonbit_incref(moonbit_poll);
  cb->code(cb, moonbit_poll, status, events);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_poll_start(
  moonbit_uv_poll_t *poll,
  int32_t events,
  moonbit_uv_poll_cb_t *cb
) {
  moonbit_uv_poll_set_data(poll, cb);
  int status = uv_poll_start(&poll->poll, events, moonbit_uv_poll_cb);
  moonbit_decref(poll);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_poll_stop(moonbit_uv_poll_t *poll) {
  moonbit_uv_tracef("poll = %p\n", (void *)poll);
  moonbit_uv_tracef("poll->rc = %d\n", Moonbit_object_header(poll)->rc);
  moonbit_uv_poll_set_data(poll, NULL);
  int status = uv_poll_stop(&poll->poll);
  moonbit_decref(poll);
  return status;
}