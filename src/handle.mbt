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
type Handle

///|
extern "c" fn uv_close(handle : Handle, cb : () -> Unit) = "moonbit_uv_close"

///|
pub fn Handle::close(self : Handle, cb : () -> Unit) -> Unit {
  uv_close(self, cb)
}

///|
#deprecated("Use Handle::close() instead")
pub fn[Handle : ToHandle] close(handle : Handle, cb : () -> Unit) -> Unit {
  handle.close(cb)
}

///|
extern "c" fn uv_is_closing(handle : Handle) -> Bool = "moonbit_uv_is_closing"

///|
pub fn Handle::is_closing(self : Handle) -> Bool {
  uv_is_closing(self)
}

///|
#deprecated("Use Handle::is_closing() instead")
pub fn[Handle : ToHandle] is_closing(handle : Handle) -> Bool {
  handle.is_closing()
}

///|
pub trait ToHandle {
  to_handle(Self) -> Handle
  of_handle(Handle) -> Self
  close(Self, () -> Unit) -> Unit = _
  is_closing(Self) -> Bool = _
  loop_(Self) -> Loop = _
  fileno(Self) -> OsFd raise Errno = _
}

///|
impl ToHandle with close(self, cb) {
  self.to_handle().close(cb)
}

///|
impl ToHandle with is_closing(self) {
  self.to_handle().is_closing()
}

///|
extern "c" fn uv_handle_loop(handle : Handle) -> Loop = "moonbit_uv_handle_loop"

///|
impl ToHandle with loop_(self) {
  uv_handle_loop(self.to_handle())
}

///|
pub enum HandleType {
  Unknown = 0
  Async = 1
  Check = 2
  FsEvent = 3
  FsPoll = 4
  Handle = 5
  Idle = 6
  Pipe = 7
  Poll = 8
  Prepare = 9
  Process = 10
  Stream = 11
  Tcp = 12
  Timer = 13
  Tty = 14
  Udp = 15
  Signal = 16
  File = 17
} derive(Eq, Hash)

///|
fn init {
  ignore([
    HandleType::Unknown,
    HandleType::Async,
    HandleType::Check,
    HandleType::FsEvent,
    HandleType::FsPoll,
    HandleType::Handle,
    HandleType::Idle,
    HandleType::Pipe,
    HandleType::Poll,
    HandleType::Prepare,
    HandleType::Process,
    HandleType::Stream,
    HandleType::Tcp,
    HandleType::Timer,
    HandleType::Tty,
    HandleType::Udp,
    HandleType::Signal,
    HandleType::File,
  ])
}

///|
type OsFd

///|
extern "c" fn uv_os_fd_make() -> OsFd = "moonbit_uv_os_fd_make"

///|
#borrow(fd)
extern "c" fn uv_os_fd_to_int(fd : OsFd) -> Int = "moonbit_uv_os_fd_to_int"

///|
pub fn OsFd::to_int(self : OsFd) -> Int raise Errno {
  let result = uv_os_fd_to_int(self)
  if result < 0 {
    raise Errno::of_int(result)
  }
  result
}

///|
#borrow(handle, fd)
extern "c" fn uv_fileno(handle : Handle, fd : OsFd) -> Int = "moonbit_uv_fileno"

///|
impl ToHandle with fileno(self) {
  let fd = uv_os_fd_make()
  let status = uv_fileno(self.to_handle(), fd)
  if status < 0 {
    raise Errno::of_int(status)
  }
  fd
}
