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
int32_t
moonbit_uv_cancel(uv_req_t *req) {
  moonbit_uv_tracef("req: %p\n", (void *)req);
  moonbit_uv_tracef("req->type: %s\n", uv_req_type_name(req->type));
  moonbit_uv_tracef("req->rc: %d\n", Moonbit_object_header(req)->rc);
  int32_t result = uv_cancel(req);
  moonbit_uv_tracef("result: %d\n", result);
  moonbit_decref(req);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_req_get_type(uv_req_t *req) {
  moonbit_uv_tracef("req: %p\n", (void *)req);
  moonbit_uv_tracef("req->rc: %d\n", Moonbit_object_header(req)->rc);
  int32_t req_type = uv_req_get_type(req);
  moonbit_uv_tracef("req_type: %d\n", req_type);
  moonbit_decref(req);
  return req_type;
}

MOONBIT_FFI_EXPORT
const char *
moonbit_uv_req_type_name(int32_t req_type) {
  moonbit_uv_tracef("req_type: %d\n", req_type);
  return uv_req_type_name((uv_req_type)req_type);
}
