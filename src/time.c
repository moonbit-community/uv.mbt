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

MOONBIT_FFI_EXPORT
void
moonbit_uv_sleep(uint32_t milliseconds) {
  uv_sleep(milliseconds);
}

MOONBIT_FFI_EXPORT
uint64_t
moonbit_uv_hrtime(void) {
  uint64_t hrtime = uv_hrtime();
  return hrtime;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_clock_gettime(uv_clock_id clock_id, int64_t *timespec) {
  uv_timespec64_t ts;
  int status = uv_clock_gettime(clock_id, &ts);
  timespec[0] = ts.tv_sec;
  timespec[1] = ts.tv_nsec;
  moonbit_decref(timespec);
  return status;
}

MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_gettimeofday(int64_t *timeval) {
  uv_timeval64_t tv;
  int status = uv_gettimeofday(&tv);
  timeval[0] = tv.tv_sec;
  timeval[1] = tv.tv_usec;
  moonbit_decref(timeval);
  return status;
}
