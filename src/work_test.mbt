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
test "work" {
  let uv = @uv.Loop::new()
  let mutex = @uv.Mutex::new()
  let mut error = None
  for i in 0..<2 {
    let mutex = mutex.share()
    uv.queue_work(() => @uv.sleep(50), () => (), fn(e) {
      mutex.lock()
      error = Some(e)
      mutex.unlock()
    })
    |> ignore()
  }
  uv.run(Default)
  uv.close()
  if error is Some(e) {
    raise e
  }
}
