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
test "args" {
  ignore(@uv.args())
}

///|
test "get_process_title" {
  ignore(@uv.get_process_title())
}

///|
test "set_process_title" {
  @uv.set_process_title("moonbit test")
}

///|
fn[Show : Show] println(message : Show) -> Unit {
  try {
    if @uv.os_getenv("TERM_PROGRAM") is Some("vscode") &&
      @uv.os_getenv("VSCODE_INJECTION") is None &&
      @uv.os_getenv("VSCODE_PROFILE_INITIALIZED") is None {
      @builtin.println(message)
    }
  } catch {
    _ => ()
  }
}
