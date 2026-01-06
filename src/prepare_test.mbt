// Copyright 2026 International Digital Economy Academy
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
test {
  let uv = @uv.Loop::new()
  let prepare = @uv.Prepare::new(uv)
  let mut error = None
  fn wait_for_a_while(handle : @uv.Prepare) -> Unit {
    try {
      handle.stop()
      handle.close(() => ())
    } catch {
      e => error = Some(e)
    }
  }

  prepare.start(wait_for_a_while(_))
  uv.run(Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
}
