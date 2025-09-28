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
type Pipe

///|
pub fn Pipe::to_handle(self : Pipe) -> Handle = "%identity"

///|
pub fn Pipe::to_stream(self : Pipe) -> Stream = "%identity"

///|
pub impl ToHandle for Pipe with to_handle(self) {
  self.to_handle()
}

///|
pub impl ToHandle for Pipe with of_handle(self) = "%identity"

///|
pub impl ToStream for Pipe with to_stream(self) {
  self.to_stream()
}

///|
pub impl ToStream for Pipe with of_stream(self) = "%identity"

///|
extern "c" fn uv_pipe_make() -> Pipe = "moonbit_uv_pipe_make"

///|
#owned(uv, pipe)
extern "c" fn uv_pipe_init(uv : Loop, pipe : Pipe, ipc : Bool) -> Int = "moonbit_uv_pipe_init"

///|
#owned(pipe, name)
extern "c" fn uv_pipe_bind(pipe : Pipe, name : Bytes, flags : UInt) -> Int = "moonbit_uv_pipe_bind"

///|
#owned(fds)
extern "c" fn uv_pipe(
  fds : FixedArray[Int],
  read_flags : Int,
  write_flags : Int,
) -> Int = "moonbit_uv_pipe"

///|
pub fn Pipe::new(self : Loop, ipc? : Bool = false) -> Pipe raise Errno {
  let pipe = uv_pipe_make()
  let status = uv_pipe_init(self, pipe, ipc)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return pipe
}

///|
struct PipeBindFlags(UInt)

///|
const PIPE_NO_TRUNCATE : UInt = 1U << 0

///|
pub fn PipeBindFlags::new(truncate? : Bool = true) -> PipeBindFlags {
  let mut flags = 0U
  if not(truncate) {
    flags = flags | PIPE_NO_TRUNCATE
  }
  return flags
}

///|
pub fn Pipe::bind(
  self : Pipe,
  name : Bytes,
  flags : PipeBindFlags,
) -> Unit raise Errno {
  let status = uv_pipe_bind(self, name, flags.0)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
struct PipeFlags(Int)

///|
const UV_NONBLOCK_PIPE : Int = 0x40

///|
pub fn PipeFlags::new(non_block? : Bool = true) -> PipeFlags {
  if non_block {
    UV_NONBLOCK_PIPE
  } else {
    0
  }
}

///|
pub fn pipe(
  read_flags? : PipeFlags = UV_NONBLOCK_PIPE,
  write_flags? : PipeFlags = UV_NONBLOCK_PIPE,
) -> (File, File) raise Errno {
  let fds : FixedArray[Int] = [0, 0]
  let status = uv_pipe(fds, read_flags.0, write_flags.0)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return (File(fds[0]), File(fds[1]))
}

///|
#owned(pipe)
extern "c" fn uv_pipe_open(pipe : Pipe, file : Int) -> Int = "moonbit_uv_pipe_open"

///|
pub fn Pipe::open(self : Pipe, file : File) -> Unit raise Errno {
  let status = uv_pipe_open(self, file.0)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(pipe)
extern "c" fn uv_pipe_pending_count(pipe : Pipe) -> UInt = "moonbit_uv_pipe_pending_count"

///|
pub fn Pipe::pending_count(self : Pipe) -> UInt {
  uv_pipe_pending_count(self)
}

///|
#owned(pipe)
extern "c" fn uv_pipe_pending_type(pipe : Pipe) -> HandleType = "moonbit_uv_pipe_pending_type"

///|
pub fn Pipe::pending_type(self : Pipe) -> HandleType {
  return uv_pipe_pending_type(self)
}

///|
#owned(req, handle, name)
extern "c" fn uv_pipe_connect2(
  req : Connect,
  handle : Pipe,
  name : Bytes,
  flags : UInt,
  cb : (Connect, Int) -> Unit,
) -> Int = "moonbit_uv_pipe_connect2"

///|
const UV_PIPE_NO_TRUNCATE : UInt = 1U << 0

///|
pub fn Pipe::connect(
  self : Pipe,
  name : Bytes,
  connect_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
  no_truncate? : Bool = false,
) -> Connect raise Errno {
  fn cb(_ : Connect, status : Int) {
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      connect_cb()
    }
  }

  let req = uv_connect_make()
  let mut flags = 0U
  if no_truncate {
    flags = flags | UV_PIPE_NO_TRUNCATE
  }
  let status = uv_pipe_connect2(req, self, name, flags, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
#owned(pipe)
extern "c" fn uv_pipe_chmod(pipe : Pipe, mode : Int) -> Int = "moonbit_uv_pipe_chmod"

///|
const UV_READABLE = 1

///|
const UV_WRITABLE = 2

///|
pub(all) enum PipeMode {
  Readable
  Writable
  ReadWrite
}

///|
/// Alters pipe permissions, allowing it to be accessed from processes run by
/// different users. Makes the pipe writable or readable by all users.
pub fn Pipe::chmod(self : Pipe, mode : PipeMode) -> Unit raise Errno {
  let mode = match mode {
    Readable => UV_READABLE
    Writable => UV_WRITABLE
    ReadWrite => UV_READABLE | UV_WRITABLE
  }
  let status = uv_pipe_chmod(self, mode)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
/// Set the number of pending pipe instance handles when the pipe server is waiting for connections.
///
/// **NOTE**: This setting applies to Windows only.
#owned(self)
pub extern "c" fn Pipe::pending_instances(self : Pipe, count : Int) = "moonbit_uv_pipe_pending_instances"
