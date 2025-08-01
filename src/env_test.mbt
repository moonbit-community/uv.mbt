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
test "os_environ" {
  let environ = @uv.os_environ()
  for name, value in environ {
    assert_eq(@uv.os_getenv(@encoding.encode(encoding=UTF8, name)), Some(value))
  }
}

///|
test "env" {
  let name = "UV_MBT_TEST"
  let value = "uv.mbt"
  let name_bytes = @encoding.encode(encoding=UTF8, name)
  let value_bytes = @encoding.encode(encoding=UTF8, value)
  @uv.os_setenv(name_bytes, value_bytes)
  assert_eq(@uv.os_getenv(name_bytes), Some(value))
  @uv.os_unsetenv(name_bytes)
  assert_eq(@uv.os_getenv(name_bytes), None)
}
