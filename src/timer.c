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

#include "uv#include#uv.h"
#include "uv.h"

typedef struct moonbit_uv_timer_cb_s {
  int32_t (*code)(struct moonbit_uv_timer_cb_s *, uv_timer_t *timer);
} moonbit_uv_timer_cb_t;

typedef struct moonbit_uv_timer_s {
  uv_timer_t timer;
} moonbit_uv_timer_t;

static inline void
moonbit_uv_timer_finalize(void *object) {
  moonbit_uv_timer_t *timer = (moonbit_uv_timer_t *)object;
  moonbit_decref(timer->timer.loop);
  if (timer->timer.data) {
    moonbit_decref(timer->timer.data);
  }
}

static inline void
moonbit_uv_timer_set_data(moonbit_uv_timer_t *timer, void *data) {
  if (timer->timer.data) {
    moonbit_decref(timer->timer.data);
  }
  timer->timer.data = data;
}

MOONBIT_FFI_EXPORT
moonbit_uv_timer_t *
moonbit_uv_timer_make(void) {
  moonbit_uv_timer_t *timer =
    (moonbit_uv_timer_t *)moonbit_make_external_object(
      moonbit_uv_timer_finalize, sizeof(moonbit_uv_timer_t)
    );
  memset(timer, 0, sizeof(moonbit_uv_timer_t));
  return timer;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_timer_init(uv_loop_t *loop, moonbit_uv_timer_t *timer) {
  moonbit_uv_tracef("loop = %p\n", (void *)loop);
  moonbit_uv_tracef("timer = %p\n", (void *)timer);
  return uv_timer_init(loop, &timer->timer);
}

static inline void
moonbit_uv_timer_cb(uv_timer_t *timer) {
  moonbit_uv_timer_cb_t *cb = timer->data;
  moonbit_incref(cb);
  moonbit_incref(timer);
  cb->code(cb, timer);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_timer_start(
  moonbit_uv_timer_t *timer,
  moonbit_uv_timer_cb_t *cb,
  uint64_t timeout,
  uint64_t repeat
) {
  moonbit_uv_tracef("timer = %p\n", (void *)timer);
  moonbit_uv_tracef("timer->rc = %d\n", Moonbit_object_header(timer)->rc);
  moonbit_uv_timer_set_data(timer, cb);
  int result =
    uv_timer_start(&timer->timer, moonbit_uv_timer_cb, timeout, repeat);
  moonbit_decref(timer);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_timer_stop(moonbit_uv_timer_t *timer) {
  moonbit_uv_timer_set_data(timer, NULL);
  int status = uv_timer_stop(&timer->timer);
  moonbit_decref(timer);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_timer_set_repeat(moonbit_uv_timer_t *timer, uint64_t repeat) {
  uv_timer_set_repeat(&timer->timer, repeat);
  moonbit_decref(timer);
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_timer_get_repeat(moonbit_uv_timer_t *timer) {
  uint64_t repeat = uv_timer_get_repeat(&timer->timer);
  moonbit_decref(timer);
  return repeat;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_timer_get_due_in(moonbit_uv_timer_t *timer) {
  uint64_t due_in = uv_timer_get_due_in(&timer->timer);
  moonbit_decref(timer);
  return due_in;
}
