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
type GetAddrInfo

///|
extern "c" fn uv_getaddrinfo_make() -> GetAddrInfo = "moonbit_uv_getaddrinfo_make"

///|
pub impl ToReq for GetAddrInfo with to_req(self : GetAddrInfo) -> Req = "%identity"

///|
type AddrInfoHints

///|
extern "c" fn uv_addrinfo_hints(
  flags : Int,
  family : Int,
  socktype : Int,
  protocol : Int,
) -> AddrInfoHints = "moonbit_uv_addrinfo_hints"

///|
struct AddrInfoFlags(Int)

///|
extern "c" fn uv_AI_PASSIVE() -> Int = "moonbit_uv_AI_PASSIVE"

///|
let _AI_PASSIVE : Int = uv_AI_PASSIVE()

///|
extern "c" fn uv_AI_CANONNAME() -> Int = "moonbit_uv_AI_CANONNAME"

///|
let _AI_CANONNAME : Int = uv_AI_CANONNAME()

///|
extern "c" fn uv_AI_NUMERICHOST() -> Int = "moonbit_uv_AI_NUMERICHOST"

///|
let _AI_NUMERICHOST : Int = uv_AI_NUMERICHOST()

///|
extern "c" fn uv_AI_NUMERICSERV() -> Int = "moonbit_uv_AI_NUMERICSERV"

///|
let _AI_NUMERICSERV : Int = uv_AI_NUMERICSERV()

///|
extern "c" fn uv_AI_ALL() -> Int = "moonbit_uv_AI_ALL"

///|
let _AI_ALL : Int = uv_AI_ALL()

///|
extern "c" fn uv_AI_ADDRCONFIG() -> Int = "moonbit_uv_AI_ADDRCONFIG"

///|
let _AI_ADDRCONFIG : Int = uv_AI_ADDRCONFIG()

///|
extern "c" fn uv_AI_V4MAPPED() -> Int = "moonbit_uv_AI_V4MAPPED"

///|
let _AI_V4MAPPED : Int = uv_AI_V4MAPPED()

///|
pub fn AddrInfoFlags::new(
  passive? : Bool = false,
  canonname? : Bool = false,
  numeric_host? : Bool = false,
  numeric_serv? : Bool = false,
  all? : Bool = false,
  addrconfig? : Bool = false,
  v4mapped? : Bool = false,
) -> AddrInfoFlags {
  let mut flags = 0
  if passive {
    flags = flags | _AI_PASSIVE
  }
  if canonname {
    flags = flags | _AI_CANONNAME
  }
  if numeric_host {
    flags = flags | _AI_NUMERICHOST
  }
  if numeric_serv {
    flags = flags | _AI_NUMERICSERV
  }
  if all {
    flags = flags | _AI_ALL
  }
  if addrconfig {
    flags = flags | _AI_ADDRCONFIG
  }
  if v4mapped {
    flags = flags | _AI_V4MAPPED
  }
  return flags
}

///|
pub fn AddrInfoHints::new(
  flags? : AddrInfoFlags,
  family? : Int,
  socktype? : @socket.Type,
  protocol? : Int,
) -> AddrInfoHints {
  let flags = match flags {
    Some(flags) => flags.inner()
    None => 0
  }
  let family = match family {
    Some(family) => family
    None => 0
  }
  let socktype = match socktype {
    Some(socktype) => socktype.to_int()
    None => 0
  }
  let protocol = match protocol {
    Some(protocol) => protocol
    None => 0
  }
  uv_addrinfo_hints(flags, family, socktype, protocol)
}

///|
extern "c" fn AddrInfoHints::nil() -> AddrInfoHints = "moonbit_c_null"

///|
priv type AddrInfoResults

///|
#borrow(addrinfo_results, cb)
extern "c" fn uv_addrinfo_results_iterate(
  addrinfo_results : AddrInfoResults,
  cb : (Int, Int, @socket.Type, Int, @socket.Sockaddr, @c.Pointer[Byte]) -> Bool,
) -> Bool = "moonbit_uv_addrinfo_results_iterate"

///|
extern "c" fn uv_IF_NAMESIZE() -> Int = "moonbit_uv_IF_NAMESIZE"

///|
let _IF_NAMESIZE : Int = uv_IF_NAMESIZE()

///|
struct AddrInfo {
  family : Int
  socktype : @socket.Type
  protocol : Int
  addr : @socket.Sockaddr
  canonname : Bytes?
}

///|
pub fn AddrInfo::family(self : AddrInfo) -> Int {
  self.family
}

///|
pub fn AddrInfo::addr(self : AddrInfo) -> @socket.Sockaddr {
  self.addr
}

///|
pub fn AddrInfo::socktype(self : AddrInfo) -> @socket.Type {
  self.socktype
}

///|
pub fn AddrInfo::protocol(self : AddrInfo) -> Int {
  self.protocol
}

///|
pub fn AddrInfo::canonname(self : AddrInfo) -> Bytes? {
  self.canonname
}

///|
fn AddrInfoResults::iter(self : AddrInfoResults) -> Iter[AddrInfo] {
  Iter::new(fn(each) {
    if uv_addrinfo_results_iterate(self, fn(
        _,
        family,
        socktype,
        protocol,
        addr,
        canonname,
      ) {
        let canonname = if canonname.is_null() {
          None
        } else {
          let buffer = @buffer.new()
          for i = 0; canonname[i] != 0; i = i + 1 {
            buffer.write_byte(canonname[i])
          }
          Some(buffer.contents())
        }
        match each({ family, socktype, protocol, addr, canonname }) {
          IterEnd => true
          IterContinue => false
        }
      }) {
      return IterEnd
    } else {
      return IterContinue
    }
  })
}

///|
#owned(uv, req, node, service, hints)
extern "c" fn uv_getaddrinfo(
  uv : Loop,
  req : GetAddrInfo,
  getaddrinfo_cb : (GetAddrInfo, Int, AddrInfoResults) -> Unit,
  node : Bytes,
  service : Bytes,
  hints : AddrInfoHints,
) -> Int = "moonbit_uv_getaddrinfo"

///|
pub fn Loop::getaddrinfo(
  self : Loop,
  getaddrinfo_cb : (Iter[AddrInfo]) -> Unit,
  error_cb : (Errno) -> Unit,
  node : Bytes,
  service : Bytes,
  hints? : AddrInfoHints,
) -> GetAddrInfo raise Errno {
  fn uv_cb(_ : GetAddrInfo, status : Int, addrinfo : AddrInfoResults) {
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      getaddrinfo_cb(addrinfo.iter())
    }
  }

  let req = uv_getaddrinfo_make()
  let hints = match hints {
    Some(hints) => hints
    None => AddrInfoHints::nil()
  }
  let status = uv_getaddrinfo(self, req, uv_cb, node, service, hints)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}
