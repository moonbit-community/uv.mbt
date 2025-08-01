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
  let tmpdir_bytes = @encoding.encode(encoding=UTF8, tmpdir)
  let stat = uv.fs_stat_sync(tmpdir_bytes)
  @json.inspect(stat.type_(), content="dir")
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
  let homedir_bytes = @encoding.encode(encoding=UTF8, homedir)
  let stat = uv.fs_stat_sync(homedir_bytes)
  @json.inspect(stat.type_(), content="dir")
  uv.close()
}

///|
test "chdir" {
  let uv = @uv.Loop::new()
  let old_cwd = @uv.cwd()
  let old_cwd_bytes = @encoding.encode(encoding=UTF8, old_cwd + "/test/fixtures")
  let dir = uv.fs_realpath_sync(old_cwd_bytes)
  @uv.chdir(@encoding.encode(encoding=UTF8, "test/fixtures"))
  let new_cwd = @uv.cwd()
  assert_eq(new_cwd, dir)
  @uv.chdir(@encoding.encode(encoding=UTF8, old_cwd))
  uv.close()
}
