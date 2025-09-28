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
test "metrics" {
  let uv = @uv.Loop::new()
  uv.configure(MeasureIdleTime)
  let errors = []
  uv.fs_open(
    "test/fixtures/example.txt",
    @uv.OpenFlags::read_only(),
    0o644,
    file => {
      let bytes = Bytes::make(1024, 0)
      try
        uv.fs_read(file, [bytes], _ => (), error => errors.push(error))
        |> ignore()
      catch {
        error => errors.push(error)
      }
    },
    error => errors.push(error),
  )
  |> ignore()
  uv.run(Default)
  let metrics = uv.metrics_info()
  ignore(metrics.loop_count())
  ignore(metrics.events())
  ignore(metrics.events_waiting())
  ignore(uv.metrics_idle_time())
  uv.close()
}
