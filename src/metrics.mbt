// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
struct Metrics(Bytes)

///|
#owned(metrics)
extern "c" fn uv_metrics_get_loop_count(metrics : Metrics) -> UInt64 = "moonbit_uv_metrics_get_loop_count"

///|
#owned(metrics)
extern "c" fn uv_metrics_get_events(metrics : Metrics) -> UInt64 = "moonbit_uv_metrics_get_events"

///|
#owned(metrics)
extern "c" fn uv_metrics_get_events_waiting(metrics : Metrics) -> UInt64 = "moonbit_uv_metrics_get_events_waiting"

///|
extern "c" fn uv_metrics_make() -> Metrics = "moonbit_uv_metrics_make"

///|
#owned(uv, metrics)
extern "c" fn uv_metrics_info(uv : Loop, metrics : Metrics) -> Int = "moonbit_uv_metrics_info"

///|
#owned(uv)
extern "c" fn uv_metrics_idle_time(uv : Loop) -> UInt64 = "moonbit_uv_metrics_idle_time"

///|
#as_free_fn
pub fn Loop::metrics_info(self : Loop) -> Metrics raise Errno {
  let metrics = uv_metrics_make()
  let status = uv_metrics_info(self, metrics)
  if status < 0 {
    raise Errno::of_int(status)
  }
  metrics
}

///|
pub fn Metrics::loop_count(self : Metrics) -> UInt64 {
  uv_metrics_get_loop_count(self)
}

///|
pub fn Metrics::events(self : Metrics) -> UInt64 {
  uv_metrics_get_events(self)
}

///|
pub fn Metrics::events_waiting(self : Metrics) -> UInt64 {
  uv_metrics_get_events_waiting(self)
}

///|
#as_free_fn
pub fn Loop::metrics_idle_time(self : Loop) -> UInt64 {
  uv_metrics_idle_time(self)
}
