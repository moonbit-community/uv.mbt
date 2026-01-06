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
#include <stdint.h>

MOONBIT_FFI_EXPORT
uv_tty_t *
moonbit_uv_tty_make(void) {
  uv_tty_t *tty = (uv_tty_t *)moonbit_make_bytes(sizeof(uv_tty_t), 0);
  memset(tty, 0, sizeof(uv_tty_t));
  return tty;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tty_init(uv_loop_t *loop, uv_tty_t *handle, int32_t fd) {
  int result = uv_tty_init(loop, handle, fd, 0);
  moonbit_decref(loop);
  moonbit_decref(handle);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tty_set_mode(uv_tty_t *handle, uv_tty_mode_t mode) {
  int result = uv_tty_set_mode(handle, mode);
  moonbit_decref(handle);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tty_reset_mode(void) {
  int result = uv_tty_reset_mode();
  return result;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tty_get_winsize(uv_tty_t *handle, int32_t *width, int32_t *height) {
  int status = uv_tty_get_winsize(handle, width, height);
  moonbit_decref(handle);
  moonbit_decref(width);
  moonbit_decref(height);
  return status;
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_tty_set_vterm_state(uv_tty_vtermstate_t state) {
  uv_tty_set_vterm_state(state);
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tty_get_vterm_state(uv_tty_vtermstate_t *state) {
  return uv_tty_get_vterm_state(state);
}
