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
    @assert.eq(@uv.os_getenv(name), Some(value))
  }
}

///|
test "env" {
  let name : Bytes = "UV_MBT_TEST"
  let value : Bytes = "uv.mbt"
  @uv.os_setenv(name, value)
  @assert.eq(@uv.os_getenv(name), Some(value))
  @uv.os_unsetenv(name)
  @assert.eq(@uv.os_getenv(name), None)
}
