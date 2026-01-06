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
test "is_readable" {
  let uv = @uv.Loop::new()
  let stream = @uv.Pipe::new(uv, ipc=false)
  @json.inspect(stream.is_readable(), content=false)
  @json.inspect(stream.is_writable(), content=false)
  stream.close(() => ())
  uv.run(Default)
  uv.stop()
  uv.close()
}

///|
test "write_queue_size" {
  let uv = @uv.Loop::new()
  let stream = @uv.Pipe::new(uv, ipc=false)
  ignore(stream.write_queue_size())
  stream.close(() => ())
  uv.run(Default)
  uv.stop()
  uv.close()
}
