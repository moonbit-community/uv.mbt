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

#include "uv.h"

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

MOONBIT_FFI_EXPORT
void
moonbit_uv_close(uv_handle_t *handle, moonbit_uv_close_cb_t *close_cb) {
  moonbit_uv_tracef("cb = %p\n", (void *)close_cb);
  moonbit_uv_tracef("cb->rc = %d\n", Moonbit_object_header(close_cb)->rc);
  moonbit_uv_tracef("handle = %p\n", (void *)handle);
  moonbit_uv_tracef("handle->rc = %d\n", Moonbit_object_header(handle)->rc);
  moonbit_uv_handle_set_data(handle, close_cb);
  moonbit_uv_tracef("handle->type = %s\n", uv_handle_type_name(handle->type));
  moonbit_uv_tracef(
    "uv_has_ref(handle) = %s\n", uv_has_ref(handle) ? "true" : "false"
  );
  uv_close(handle, moonbit_uv_close_cb);
  moonbit_decref(handle);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_is_closing(uv_handle_t *handle) {
  int32_t is_closing = uv_is_closing(handle);
  moonbit_decref(handle);
  return is_closing;
}

MOONBIT_FFI_EXPORT
uv_loop_t *
moonbit_uv_handle_loop(uv_handle_t *handle) {
  uv_loop_t *loop = handle->loop;
  moonbit_incref(loop);
  moonbit_decref(handle);
  return loop;
}
