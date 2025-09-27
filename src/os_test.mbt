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
test "tmpdir" {
  let uv = @uv.Loop::new()
  let tmpdir = @uv.os_tmpdir()
  let stat = uv.fs_stat_sync(tmpdir)
  @assert.t(stat.type_() is Dir)
  uv.close()
}

///|
test "exepath" {
  println(@uv.exepath())
}

///|
test "homedir" {
  let uv = @uv.Loop::new()
  let homedir = @uv.os_homedir()
  let stat = uv.fs_stat_sync(homedir)
  @assert.t(stat.type_() is Dir)
  uv.close()
}

///|
test "chdir" {
  let uv = @uv.Loop::new()
  let old_cwd = @uv.cwd()
  let dir = uv.fs_realpath_sync(old_cwd + "/test/fixtures")
  @uv.chdir("test/fixtures")
  let new_cwd = @uv.cwd()
  @assert.eq(new_cwd, dir)
  @uv.chdir(old_cwd)
  uv.close()
}

///|
test "getpid" {
  ignore(@uv.os_getpid())
}

///|
test "getppid" {
  ignore(@uv.os_getppid())
}

///|
test "gethostname" {
  ignore(@uv.os_gethostname())
}

///|
test "uptime" {
  ignore(@uv.uptime())
}

///|
test "resident_set_memory" {
  ignore(@uv.resident_set_memory())
}
