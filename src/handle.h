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

#ifndef MOONBIT_UV_HANDLE_H
#define MOONBIT_UV_HANDLE_H

#include "moonbit.h"
#include "uv#include#uv.h"

#include "uv.h"

typedef struct moonbit_uv_close_cb {
  int32_t (*code)(struct moonbit_uv_close_cb *);
} moonbit_uv_close_cb_t;

static inline void
moonbit_uv_close_cb(uv_handle_t *handle) {
  moonbit_uv_tracef("handle = %p\n", (void *)handle);
  moonbit_uv_tracef("handle->rc = %d\n", Moonbit_object_header(handle)->rc);
  moonbit_uv_tracef("handle->type = %s\n", uv_handle_type_name(handle->type));
  moonbit_uv_tracef(
    "uv_has_ref(handle) = %s\n", uv_has_ref(handle) ? "true" : "false"
  );
  moonbit_uv_close_cb_t *cb = handle->data;
  moonbit_uv_tracef("cb = %p\n", (void *)cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(cb)->rc);
  handle->data = NULL;
  moonbit_decref(handle);
  cb->code(cb);
}

static inline void
moonbit_uv_handle_set_data(uv_handle_t *handle, void *cb) {
  if (handle->data) {
    moonbit_decref(handle->data);
  }
  handle->data = cb;
}

#endif // MOONBIT_UV_HANDLE_H
