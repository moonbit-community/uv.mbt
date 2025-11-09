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

typedef struct moonbit_uv_prepare_s {
  uv_prepare_t prepare;
} moonbit_uv_prepare_t;

typedef struct moonbit_uv_prepare_cb {
  int32_t (*code)(struct moonbit_uv_prepare_cb *, moonbit_uv_prepare_t *);
} moonbit_uv_prepare_cb_t;

static inline void
moonbit_uv_prepare_finalize(void *object) {
  moonbit_uv_prepare_t *prepare = (moonbit_uv_prepare_t *)object;
  moonbit_uv_tracef("prepare = %p\n", (void *)prepare);
  moonbit_uv_tracef("prepare->rc = %d\n", Moonbit_object_header(prepare)->rc);
  if (prepare->prepare.loop) {
    moonbit_uv_tracef(
      "prepare->prepare.loop = %p\n", (void *)prepare->prepare.loop
    );
    moonbit_uv_tracef(
      "prepare->prepare.loop->rc = %d\n",
      Moonbit_object_header(prepare->prepare.loop)->rc
    );
    moonbit_decref(prepare->prepare.loop);
    prepare->prepare.loop = NULL;
  }
  if (prepare->prepare.data) {
    moonbit_uv_tracef(
      "prepare->prepare.data = %p\n", (void *)prepare->prepare.data
    );
    moonbit_uv_tracef(
      "prepare->prepare.data->rc = %d\n",
      Moonbit_object_header(prepare->prepare.data)->rc
    );
    moonbit_decref(prepare->prepare.data);
    prepare->prepare.data = NULL;
  }
}

static inline void
moonbit_uv_prepare_set_data(moonbit_uv_prepare_t *prepare, void *data) {
  if (prepare->prepare.data) {
    moonbit_decref(prepare->prepare.data);
  }
  prepare->prepare.data = data;
}

MOONBIT_FFI_EXPORT
moonbit_uv_prepare_t *
moonbit_uv_prepare_make(void) {
  moonbit_uv_prepare_t *prepare = moonbit_make_external_object(
    moonbit_uv_prepare_finalize, sizeof(moonbit_uv_prepare_t)
  );
  memset(prepare, 0, sizeof(moonbit_uv_prepare_t));
  moonbit_uv_tracef("prepare = %p\n", (void *)prepare);
  return prepare;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_prepare_init(uv_loop_t *loop, moonbit_uv_prepare_t *prepare) {
  return uv_prepare_init(loop, &prepare->prepare);
}

static inline void
moonbit_uv_prepare_cb(uv_prepare_t *prepare) {
  moonbit_uv_prepare_t *moonbit_prepare =
    containerof(prepare, moonbit_uv_prepare_t, prepare);
  moonbit_uv_tracef("moonbit_prepare = %p\n", (void *)moonbit_prepare);
  moonbit_uv_tracef(
    "moonbit_prepare->rc = %d\n", Moonbit_object_header(moonbit_prepare)->rc
  );
  moonbit_uv_prepare_cb_t *cb = moonbit_prepare->prepare.data;
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  moonbit_incref(cb);
  moonbit_incref(moonbit_prepare);
  cb->code(cb, moonbit_prepare);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_prepare_start(
  moonbit_uv_prepare_t *prepare,
  moonbit_uv_prepare_cb_t *cb
) {
  moonbit_uv_prepare_set_data(prepare, cb);
  int status = uv_prepare_start(&prepare->prepare, moonbit_uv_prepare_cb);
  moonbit_decref(prepare);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_prepare_stop(moonbit_uv_prepare_t *prepare) {
  moonbit_uv_tracef("prepare = %p\n", (void *)prepare);
  moonbit_uv_tracef("prepare->rc = %d\n", Moonbit_object_header(prepare)->rc);
  moonbit_uv_prepare_set_data(prepare, NULL);
  int status = uv_prepare_stop(&prepare->prepare);
  moonbit_decref(prepare);
  return status;
}
