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

MOONBIT_FFI_EXPORT
uv_metrics_t *
moonbit_uv_metrics_make(void) {
  return (uv_metrics_t *)moonbit_make_bytes(sizeof(uv_metrics_t), 0);
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_metrics_get_loop_count(uv_metrics_t *metrics) {
  uint64_t count = metrics->loop_count;
  moonbit_decref(metrics);
  return count;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_metrics_get_events(uv_metrics_t *metrics) {
  uint64_t events = metrics->events;
  moonbit_decref(metrics);
  return events;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_metrics_get_events_waiting(uv_metrics_t *metrics) {
  uint64_t events_waiting = metrics->events_waiting;
  moonbit_decref(metrics);
  return events_waiting;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_metrics_info(uv_loop_t *loop, uv_metrics_t *metrics) {
  int32_t status = uv_metrics_info(loop, metrics);
  moonbit_decref(loop);
  moonbit_decref(metrics);
  return status;
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_metrics_idle_time(uv_loop_t *loop) {
  uint64_t idle_time = uv_metrics_idle_time(loop);
  moonbit_decref(loop);
  return idle_time;
}
