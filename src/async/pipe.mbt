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
type Pipe @uv.Pipe

///|
pub fn Pipe::new(ipc~ : Bool = false) -> Pipe raise {
  let uv = uv()
  @uv.Pipe::new(uv, ipc~)
}

///|
pub async fn Pipe::close(self : Pipe) -> Unit {
  async_suspend(fn(resolve) { self.inner().close(fn(_) { resolve(()) }) })
}

///|
pub impl Readable for Pipe with read(self : Pipe) {
  self.inner().to_stream() |> Readable::read()
}

///|
pub impl Writable for Pipe with write(self : Pipe, bytes : Iter[@bytes.View]) {
  Writable::write(self.inner().to_stream(), bytes)
}
