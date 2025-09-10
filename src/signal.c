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

#include "handle.h"

typedef struct moonbit_uv_signal_s {
  uv_signal_t signal;
} moonbit_uv_signal_t;

static inline void
moonbit_uv_signal_finalize(void *object) {
  moonbit_uv_signal_t *signal = object;
  if (signal->signal.loop) {
    moonbit_decref(signal->signal.loop);
  }
  if (signal->signal.data) {
    moonbit_decref(signal->signal.data);
  }
}

MOONBIT_FFI_EXPORT
moonbit_uv_signal_t *
moonbit_uv_signal_make(void) {
  moonbit_uv_signal_t *signal =
    (moonbit_uv_signal_t *)moonbit_make_external_object(
      moonbit_uv_signal_finalize, sizeof(moonbit_uv_signal_t)
    );
  memset(signal, 0, sizeof(moonbit_uv_signal_t));
  return signal;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_signal_init(uv_loop_t *loop, moonbit_uv_signal_t *signal) {
  int status = uv_signal_init(loop, &signal->signal);
  moonbit_decref(signal);
  return status;
}

typedef struct moonbit_uv_signal_cb_s {
  int32_t (*code)(
    struct moonbit_uv_signal_cb_s *,
    uv_signal_t *signal,
    int signum
  );
} moonbit_uv_signal_cb_t;

static inline void
moonbit_uv_signal_cb(uv_signal_t *signal, int signum) {
  moonbit_uv_signal_cb_t *cb = signal->data;
  moonbit_incref(cb);
  moonbit_incref(signal);
  cb->code(cb, signal, signum);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_signal_start(
  moonbit_uv_signal_t *signal,
  moonbit_uv_signal_cb_t *cb,
  int32_t signum
) {
  moonbit_uv_handle_set_data((uv_handle_t *)&signal->signal, cb);
  int32_t status =
    uv_signal_start(&signal->signal, moonbit_uv_signal_cb, signum);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_signal_stop(moonbit_uv_signal_t *signal) {
  moonbit_uv_handle_set_data((uv_handle_t *)&signal->signal, NULL);
  int32_t status = uv_signal_stop(&signal->signal);
  moonbit_decref(signal);
  moonbit_decref(signal);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGHUP(void) {
  return SIGHUP;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGINT(void) {
  return SIGINT;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGQUIT(void) {
  return SIGQUIT;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGABRT(void) {
  return SIGABRT;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGTERM(void) {
  return SIGTERM;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGWINCH(void) {
  return SIGWINCH;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGPIPE(void) {
#ifdef _WIN32
  return -1;
#else
  return SIGPIPE;
#endif
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGPROF(void) {
#ifdef _WIN32
  return -1;
#else
  return SIGPROF;
#endif
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_SIGTSTP(void) {
#ifdef _WIN32
  return -1;
#else
  return SIGTSTP;
#endif
}
