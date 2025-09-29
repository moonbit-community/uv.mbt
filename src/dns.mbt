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
  family? : AddressFamily,
  socktype? : @socket.Type,
  protocol? : Protocol,
) -> AddrInfoHints {
  let flags = match flags {
    Some(flags) => flags.0
    None => 0
  }
  let family = match family {
    Some(family) => family.to_int()
    None => 0
  }
  let socktype = match socktype {
    Some(socktype) => socktype.to_int()
    None => 0
  }
  let protocol = match protocol {
    Some(protocol) => protocol.to_int()
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
  cb : (Int, Int, Int, Int, Sockaddr, @c.Pointer[Byte]) -> Bool,
) -> Bool = "moonbit_uv_addrinfo_results_iterate"

///|
struct AddrInfo {
  family : Int
  socktype : Int
  protocol : Int
  addr : Sockaddr
  canonname : Bytes?
}

///|
pub fn AddrInfo::family(
  self : AddrInfo,
) -> AddressFamily? raise InvalidAddressFamily {
  if self.family == @inet.family {
    Some(AddressFamily::Inet)
  } else if self.family == @inet6.family {
    Some(AddressFamily::Inet6)
  } else if self.family == 0 {
    None
  } else {
    raise InvalidAddressFamily(self.family)
  }
}

///|
pub fn AddrInfo::addr(self : AddrInfo) -> Sockaddr {
  self.addr
}

///|
pub suberror InvalidSocketType Int derive(Show, ToJson)

///|
pub fn AddrInfo::socktype(
  self : AddrInfo,
) -> @socket.Type? raise InvalidSocketType {
  if self.socktype == 0 {
    return None
  }
  match @socket.Type::of_int(self.socktype) {
    Some(type_) => Some(type_)
    None => raise InvalidSocketType(self.socktype)
  }
}

///|
pub fn AddrInfo::protocol(
  self : AddrInfo,
) -> @ip.Protocol? raise InvalidProtocol {
  if self.protocol == 0 {
    return None
  }
  match @ip.Protocol::of_int(self.protocol) {
    Some(protocol) => Some(protocol)
    None => raise InvalidProtocol(self.protocol)
  }
}

///|
pub fn AddrInfo::canonname(self : AddrInfo) -> Bytes? {
  self.canonname
}

///|
fn AddrInfoResults::iter(self : AddrInfoResults) -> Iter[AddrInfo] {
  Iter::new(fn(yield_) {
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
        match yield_({ family, socktype, protocol, addr, canonname }) {
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
#as_free_fn
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

///|
type GetNameInfo

///|
extern "c" fn uv_getnameinfo_make() -> GetNameInfo = "moonbit_uv_getnameinfo_make"

///|
pub impl ToReq for GetNameInfo with to_req(self : GetNameInfo) -> Req = "%identity"

///|
#owned(uv, req, getnameinfo_cb, addr)
extern "c" fn uv_getnameinfo(
  uv : Loop,
  req : GetNameInfo,
  getnameinfo_cb : (GetNameInfo, Int, Bytes?, Bytes?) -> Unit,
  addr : Sockaddr,
  flags : Int,
) -> Int = "moonbit_uv_getnameinfo"

///|
#as_free_fn
pub fn Loop::getnameinfo(
  self : Loop,
  getnameinfo_cb : (Bytes?, Bytes?) -> Unit,
  error_cb : (Errno) -> Unit,
  addr : Sockaddr,
  flags? : Int = 0,
) -> GetNameInfo raise Errno {
  fn uv_cb(_ : GetNameInfo, status : Int, hostname : Bytes?, service : Bytes?) {
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      getnameinfo_cb(hostname, service)
    }
  }

  let req = uv_getnameinfo_make()
  let status = uv_getnameinfo(self, req, uv_cb, addr, flags)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}
