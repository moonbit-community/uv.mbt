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
type Req

///|
pub trait ToReq {
  to_req(Self) -> Req
}

///|
pub trait Cancelable: ToReq {
  cancel(Self) -> Unit raise Errno = _
}

///|
extern "c" fn uv_cancel(req : Req) -> Int = "moonbit_uv_cancel"

///|
impl Cancelable with cancel(self : Self) -> Unit raise Errno {
  let result = uv_cancel(self.to_req())
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
pub impl Cancelable for Fs
