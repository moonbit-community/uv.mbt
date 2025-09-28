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
type Poll

///|
pub impl ToHandle for Poll with to_handle(poll : Poll) -> Handle = "%identity"

///|
pub impl ToHandle for Poll with of_handle(handle : Handle) -> Poll = "%identity"

///|
struct PollEvent(Int)

///|
const POLL_EVENT_READABLE = 1

///|
const POLL_EVENT_WRITABLE = 2

///|
const POLL_EVENT_DISCONNECT = 4

///|
const POLL_EVENT_PRIORITIZED = 8

///|
pub fn PollEvent::readable() -> PollEvent {
  POLL_EVENT_READABLE
}

///|
pub fn PollEvent::is_readable(self : PollEvent) -> Bool {
  (self.0 & POLL_EVENT_READABLE) != 0
}

///|
pub fn PollEvent::writable() -> PollEvent {
  POLL_EVENT_WRITABLE
}

///|
pub fn PollEvent::is_writable(self : PollEvent) -> Bool {
  (self.0 & POLL_EVENT_WRITABLE) != 0
}

///|
pub fn PollEvent::disconnect() -> PollEvent {
  POLL_EVENT_DISCONNECT
}

///|
pub fn PollEvent::is_disconnect(self : PollEvent) -> Bool {
  (self.0 & POLL_EVENT_DISCONNECT) != 0
}

///|
pub fn PollEvent::prioritized() -> PollEvent {
  POLL_EVENT_PRIORITIZED
}

///|
pub fn PollEvent::is_prioritized(self : PollEvent) -> Bool {
  (self.0 & POLL_EVENT_PRIORITIZED) != 0
}

///|
pub impl BitOr for PollEvent with lor(self : PollEvent, other : PollEvent) -> PollEvent {
  self.0 | other.0
}

///|
pub impl BitAnd for PollEvent with land(self : PollEvent, other : PollEvent) -> PollEvent {
  self.0 & other.0
}

///|
extern "c" fn uv_poll_make() -> Poll = "moonbit_uv_poll_make"

///|
#owned(uv, poll)
extern "c" fn uv_poll_init(uv : Loop, poll : Poll, fd : Int) -> Int = "moonbit_uv_poll_init"

///|
pub fn Poll::file(self : Loop, fd : File) -> Poll raise Errno {
  let poll = uv_poll_make()
  let status = uv_poll_init(self, poll, fd.0)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return poll
}

///|
#owned(uv, poll, socket)
extern "c" fn uv_poll_init_socket(
  uv : Loop,
  poll : Poll,
  socket : OsSock,
) -> Int = "moonbit_uv_poll_init_socket"

///|
pub fn Poll::socket(self : Loop, socket : OsSock) -> Poll raise Errno {
  let poll = uv_poll_make()
  let status = uv_poll_init_socket(self, poll, socket)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return poll
}

///|
#owned(poll)
extern "c" fn uv_poll_start(
  poll : Poll,
  events : Int,
  cb : (Poll, Int, Int) -> Unit,
) -> Int = "moonbit_uv_poll_start"

///|
#owned(poll)
extern "c" fn uv_poll_stop(poll : Poll) -> Int = "moonbit_uv_poll_stop"

///|
pub fn Poll::start(
  self : Poll,
  events : PollEvent,
  poll_cb : (Poll, PollEvent) -> Unit,
  error_cb : (Poll, Errno) -> Unit,
) -> Unit raise Errno {
  let status = uv_poll_start(self, events.0, fn(
    poll,
    status,
    events_int,
  ) {
    if status < 0 {
      error_cb(poll, Errno::of_int(status))
    } else {
      poll_cb(poll, PollEvent(events_int))
    }
  })
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn Poll::stop(self : Poll) -> Unit raise Errno {
  let status = uv_poll_stop(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
