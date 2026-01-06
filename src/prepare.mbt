// Copyright 2026 International Digital Economy Academy
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
type Prepare

///|
pub impl ToHandle for Prepare with to_handle(prepare : Prepare) -> Handle = "%identity"

///|
pub impl ToHandle for Prepare with of_handle(handle : Handle) -> Prepare = "%identity"

///|
extern "c" fn uv_prepare_make() -> Prepare = "moonbit_uv_prepare_make"

///|
#owned(uv, prepare)
extern "c" fn uv_prepare_init(uv : Loop, prepare : Prepare) -> Int = "moonbit_uv_prepare_init"

///|
pub fn Prepare::new(self : Loop) -> Prepare raise Errno {
  let prepare = uv_prepare_make()
  let status = uv_prepare_init(self, prepare)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return prepare
}

///|
#owned(prepare)
extern "c" fn uv_prepare_start(
  prepare : Prepare,
  cb : (Prepare) -> Unit,
) -> Int = "moonbit_uv_prepare_start"

///|
#owned(prepare)
extern "c" fn uv_prepare_stop(prepare : Prepare) -> Int = "moonbit_uv_prepare_stop"

///|
pub fn Prepare::start(
  self : Prepare,
  cb : (Prepare) -> Unit,
) -> Unit raise Errno {
  let status = uv_prepare_start(self, fn(prepare) { cb(prepare) })
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn Prepare::stop(self : Prepare) -> Unit raise Errno {
  let status = uv_prepare_stop(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
