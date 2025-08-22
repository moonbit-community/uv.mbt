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
  type_(self : Self) -> ReqType = _
}

///|
pub trait Cancelable: ToReq {
  cancel(Self) -> Unit raise Errno = _
}

///|
#owned(req)
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

///|
pub enum ReqType {
  Unknown = 0
  Req = 1
  Connect = 2
  Write = 3
  Shutdown = 4
  UdpSend = 5
  Fs = 6
  Work = 7
  Getaddrinfo = 8
  Getnameinfo = 9
  Random = 10
}

///|
fn init {
  ignore(ReqType::Unknown)
  ignore(ReqType::Req)
  ignore(ReqType::Connect)
  ignore(ReqType::Write)
  ignore(ReqType::Shutdown)
  ignore(ReqType::UdpSend)
  ignore(ReqType::Fs)
  ignore(ReqType::Work)
  ignore(ReqType::Getaddrinfo)
  ignore(ReqType::Getnameinfo)
  ignore(ReqType::Random)
}

///|
#owned(req)
extern "c" fn uv_req_get_type(req : Req) -> ReqType = "moonbit_uv_req_get_type"

///|
pub fn Req::type_(self : Req) -> ReqType {
  uv_req_get_type(self)
}

///|
impl ToReq with type_(self : Self) -> ReqType {
  uv_req_get_type(self.to_req())
}

///|
extern "c" fn uv_req_type_name(req_type : ReqType) -> @c.Pointer[Byte] = "moonbit_uv_req_type_name"

///|
pub fn ReqType::name(self : ReqType) -> Bytes {
  let ptr = uv_req_type_name(self)
  let buf = @buffer.new()
  for i = 0; ptr[i] != 0; i = i + 1 {
    buf.write_byte(ptr[i])
  }
  buf.contents()
}
