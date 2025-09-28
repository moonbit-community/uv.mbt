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
#owned(handle)
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
#owned(handle)
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
  os_sock(Self) -> OsSock raise Errno = _
  get_send_buffer_size(Self) -> Int raise Errno = _
  set_send_buffer_size(Self, Int) -> Unit raise Errno = _
  get_recv_buffer_size(Self) -> Int raise Errno = _
  set_recv_buffer_size(Self, Int) -> Unit raise Errno = _
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
#owned(handle)
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
}

///|
fn init {
  ignore(HandleType::Unknown)
  ignore(HandleType::Async)
  ignore(HandleType::Check)
  ignore(HandleType::FsEvent)
  ignore(HandleType::FsPoll)
  ignore(HandleType::Handle)
  ignore(HandleType::Idle)
  ignore(HandleType::Pipe)
  ignore(HandleType::Poll)
  ignore(HandleType::Prepare)
  ignore(HandleType::Process)
  ignore(HandleType::Stream)
  ignore(HandleType::Tcp)
  ignore(HandleType::Timer)
  ignore(HandleType::Tty)
  ignore(HandleType::Udp)
  ignore(HandleType::Signal)
  ignore(HandleType::File)
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

///|
#owned(handle, sock)
extern "c" fn uv_handle_os_sock(handle : Handle, sock : OsSock) -> Int = "moonbit_uv_handle_os_sock"

///|
impl ToHandle with os_sock(self : Self) -> OsSock raise Errno {
  let sock = uv_os_sock_make()
  let status = uv_handle_os_sock(self.to_handle(), sock)
  if status < 0 {
    raise Errno::of_int(status)
  }
  sock
}

///|
pub extern "c" fn guess_handle(file : File) -> HandleType = "moonbit_uv_guess_handle"

///|
#owned(handle, size)
extern "c" fn uv_send_buffer_size(handle : Handle, size : Ref[Int]) -> Int = "moonbit_uv_send_buffer_size"

///|
#owned(handle, size)
extern "c" fn uv_recv_buffer_size(handle : Handle, size : Ref[Int]) -> Int = "moonbit_uv_recv_buffer_size"

///|
impl ToHandle with get_send_buffer_size(self) {
  let size = Ref::new(0)
  let status = uv_send_buffer_size(self.to_handle(), size)
  if status < 0 {
    raise Errno::of_int(status)
  }
  size.val
}

///|
impl ToHandle with set_send_buffer_size(self, size) {
  let status = uv_send_buffer_size(self.to_handle(), Ref::new(size))
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
impl ToHandle with get_recv_buffer_size(self) {
  let size = Ref::new(0)
  let status = uv_recv_buffer_size(self.to_handle(), size)
  if status < 0 {
    raise Errno::of_int(status)
  }
  size.val
}

///|
impl ToHandle with set_recv_buffer_size(self, size) {
  let status = uv_recv_buffer_size(self.to_handle(), Ref::new(size))
  if status < 0 {
    raise Errno::of_int(status)
  }
}
