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
test "passwd" {
  let passwd = @uv.os_get_passwd()
  ignore(passwd.username())
  ignore(passwd.uid().0)
  ignore(passwd.gid().0)
  ignore(passwd.shell())
}

///|
test "passwd2" {
  if @uv.os_uname().sysname() is "Windows_NT" {
    return
  }
  let passwd = @uv.os_get_passwd2(@uv.os_get_passwd().uid())
  ignore(passwd.username())
  ignore(passwd.uid().0)
  ignore(passwd.gid().0)
  ignore(passwd.shell())
}

///|
test "group" {
  if @uv.os_uname().sysname() is "Windows_NT" {
    return
  }
  let passwd = @uv.os_get_passwd()
  let group = @uv.os_get_group(passwd.gid())
  ignore(group.name().to_json())
  ignore(group.gid().0)
  ignore(group.members().to_json())
}
