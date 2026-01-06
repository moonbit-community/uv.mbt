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
#include "uv#include#uv.h"
#include <stdlib.h>

#include "uv.h"

MOONBIT_FFI_EXPORT
uv_once_t *
moonbit_uv_once_make(void) {
  uv_once_t *once = (uv_once_t *)moonbit_make_bytes(sizeof(uv_once_t), 0);
  *once = (uv_once_t)UV_ONCE_INIT;
  return once;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_once(uv_once_t *once, void (*callback)(void)) {
  uv_once(once, callback);
  moonbit_decref(once);
}
