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

typedef struct moonbit_uv_check_s {
  uv_check_t check;
} moonbit_uv_check_t;

typedef struct moonbit_uv_check_cb {
  int32_t (*code)(struct moonbit_uv_check_cb *, moonbit_uv_check_t *);
} moonbit_uv_check_cb_t;

static inline void
moonbit_uv_check_finalize(void *object) {
  moonbit_uv_check_t *check = (moonbit_uv_check_t *)object;
  moonbit_uv_tracef("check = %p\n", (void *)check);
  moonbit_uv_tracef("check->rc = %d\n", Moonbit_object_header(check)->rc);
  if (check->check.loop) {
    moonbit_uv_tracef("check->check.loop = %p\n", (void *)check->check.loop);
    moonbit_uv_tracef(
      "check->check.loop->rc = %d\n",
      Moonbit_object_header(check->check.loop)->rc
    );
    moonbit_decref(check->check.loop);
    check->check.loop = NULL;
  }
  if (check->check.data) {
    moonbit_uv_tracef("check->check.data = %p\n", (void *)check->check.data);
    moonbit_uv_tracef(
      "check->check.data->rc = %d\n",
      Moonbit_object_header(check->check.data)->rc
    );
    moonbit_decref(check->check.data);
    check->check.data = NULL;
  }
}

static inline void
moonbit_uv_check_set_data(moonbit_uv_check_t *check, void *data) {
  if (check->check.data) {
    moonbit_decref(check->check.data);
  }
  check->check.data = data;
}

MOONBIT_FFI_EXPORT
moonbit_uv_check_t *
moonbit_uv_check_make(void) {
  moonbit_uv_check_t *check = moonbit_make_external_object(
    moonbit_uv_check_finalize, sizeof(moonbit_uv_check_t)
  );
  memset(check, 0, sizeof(moonbit_uv_check_t));
  moonbit_uv_tracef("check = %p\n", (void *)check);
  return check;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_check_init(uv_loop_t *loop, moonbit_uv_check_t *check) {
  return uv_check_init(loop, &check->check);
}

static inline void
moonbit_uv_check_cb(uv_check_t *check) {
  moonbit_uv_check_t *moonbit_check =
    containerof(check, moonbit_uv_check_t, check);
  moonbit_uv_tracef("moonbit_check = %p\n", (void *)moonbit_check);
  moonbit_uv_tracef(
    "moonbit_check->rc = %d\n", Moonbit_object_header(moonbit_check)->rc
  );
  moonbit_uv_check_cb_t *cb = moonbit_check->check.data;
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  moonbit_incref(cb);
  moonbit_incref(moonbit_check);
  cb->code(cb, moonbit_check);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_check_start(moonbit_uv_check_t *check, moonbit_uv_check_cb_t *cb) {
  moonbit_uv_check_set_data(check, cb);
  int status = uv_check_start(&check->check, moonbit_uv_check_cb);
  moonbit_decref(check);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_check_stop(moonbit_uv_check_t *check) {
  moonbit_uv_tracef("check = %p\n", (void *)check);
  moonbit_uv_tracef("check->rc = %d\n", Moonbit_object_header(check)->rc);
  moonbit_uv_check_set_data(check, NULL);
  int status = uv_check_stop(&check->check);
  moonbit_decref(check);
  return status;
}
