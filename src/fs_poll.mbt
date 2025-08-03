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
type FsPoll

///|
pub impl ToHandle for FsPoll with to_handle(self) = "%identity"

///|
pub impl ToHandle for FsPoll with of_handle(handle : Handle) -> FsPoll = "%identity"

///|
extern "c" fn uv_fs_poll_make() -> FsPoll = "moonbit_uv_fs_poll_make"

///|
extern "c" fn uv_fs_poll_init(uv : Loop, fs_poll : FsPoll) -> Int = "moonbit_uv_fs_poll_init"

///|
pub fn FsPoll::new(self : Loop) -> FsPoll raise Errno {
  let fs_poll = uv_fs_poll_make()
  let status = uv_fs_poll_init(self, fs_poll)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return fs_poll
}

///|
extern "c" fn uv_fs_poll_start(
  fs_poll : FsPoll,
  cb : (FsPoll, Int, Stat, Stat) -> Unit,
  path : Bytes,
  interval : UInt,
) -> Int = "moonbit_uv_fs_poll_start"

///|
pub fn FsPoll::start(
  self : FsPoll,
  path : Bytes,
  interval : UInt,
  poll_cb : (FsPoll, Stat, Stat) -> Unit,
  error_cb : (FsPoll, Errno) -> Unit,
) -> Unit raise Errno {
  fn uv_cb(fs_poll : FsPoll, status : Int, prev : Stat, curr : Stat) {
    if status < 0 {
      error_cb(fs_poll, Errno::of_int(status))
    } else {
      poll_cb(fs_poll, prev, curr)
    }
  }

  let status = uv_fs_poll_start(self, uv_cb, path, interval)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_poll_stop(fs_poll : FsPoll) -> Int = "moonbit_uv_fs_poll_stop"

///|
pub fn FsPoll::stop(self : FsPoll) -> Unit raise Errno {
  let status = uv_fs_poll_stop(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_poll_getpath(
  fs_poll : FsPoll,
  buffer : Bytes,
  length : FixedArray[Int],
) -> Int = "moonbit_uv_fs_poll_getpath"

///|
pub fn FsPoll::get_path(self : FsPoll) -> Bytes raise Errno {
  let mut buffer = Bytes::make(64, 0)
  let length : FixedArray[Int] = [buffer.length()]
  let mut status = uv_fs_poll_getpath(self, buffer, length)
  if status == _ENOBUFS {
    buffer = Bytes::make(length[0], 0)
    status = uv_fs_poll_getpath(self, buffer, length)
  }
  if status < 0 {
    raise Errno::of_int(status)
  }
  buffer.shrink(length[0])
  buffer
}
