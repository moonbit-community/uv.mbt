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
type Passwd

///|
extern "c" fn uv_passwd_make() -> Passwd = "moonbit_uv_passwd_make"

///|
#owned(passwd)
pub extern "c" fn Passwd::username(passwd : Passwd) -> Bytes = "moonbit_uv_passwd_get_username"

///|
#owned(passwd)
pub extern "c" fn Passwd::uid(passwd : Passwd) -> Uid = "moonbit_uv_passwd_get_uid"

///|
#owned(passwd)
pub extern "c" fn Passwd::gid(passwd : Passwd) -> Gid = "moonbit_uv_passwd_get_gid"

///|
#owned(passwd)
pub extern "c" fn Passwd::shell(passwd : Passwd) -> Bytes = "moonbit_uv_passwd_get_shell"

///|
#owned(passwd)
extern "c" fn uv_os_get_passwd(passwd : Passwd) -> Int = "moonbit_uv_os_get_passwd"

///|
/// ```
/// let passwd = @uv.os_get_passwd()
/// println(passwd.username())
/// println(passwd.uid().0)
/// println(passwd.gid().0)
/// println(passwd.shell())
/// ```
pub fn os_get_passwd() -> Passwd raise Errno {
  let passwd = uv_passwd_make()
  let status = uv_os_get_passwd(passwd)
  if status < 0 {
    raise Errno::of_int(status)
  }
  passwd
}

///|
#owned(passwd)
extern "c" fn uv_os_get_passwd2(passwd : Passwd, uid : UInt64) -> Int = "moonbit_uv_os_get_passwd2"

///|
pub fn os_get_passwd2(uid : Uid) -> Passwd raise Errno {
  let passwd = uv_passwd_make()
  let status = uv_os_get_passwd2(passwd, uid.0)
  if status < 0 {
    raise Errno::of_int(status)
  }
  passwd
}
