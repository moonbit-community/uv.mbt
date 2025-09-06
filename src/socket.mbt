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
type OsSock

///|
extern "c" fn uv_os_sock_make() -> OsSock = "moonbit_uv_os_sock_make"

///|
#borrow(sock)
extern "c" fn uv_os_sock_to_int(sock : OsSock) -> Int = "moonbit_uv_os_sock_to_int"

///|
pub fn OsSock::to_int(self : OsSock) -> Int {
  uv_os_sock_to_int(self)
}

///|
#owned(sock0, sock1)
extern "c" fn uv_socketpair(
  type_ : @socket.Type,
  protocol : Int,
  sock0 : OsSock,
  flags0 : Int,
  sock1 : OsSock,
  flags1 : Int,
) -> Int = "moonbit_uv_socketpair"

///|
pub fn socketpair(
  type_ : @socket.Type,
  protocol? : Int = 0,
  flags : (PipeFlags, PipeFlags),
) -> (OsSock, OsSock) raise Errno {
  let socks = (uv_os_sock_make(), uv_os_sock_make())
  let status = uv_socketpair(
    type_,
    protocol,
    socks.0,
    flags.0.inner(),
    socks.1,
    flags.1.inner(),
  )
  if status < 0 {
    raise Errno::of_int(status)
  }
  return socks
}
