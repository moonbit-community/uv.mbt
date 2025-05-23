///|
type GetAddrInfo

///|
extern "c" fn uv_getaddrinfo_make() -> GetAddrInfo = "moonbit_uv_getaddrinfo_make"

///|
type AddrInfoHints

///|
extern "c" fn uv_addrinfo_hints(
  flags : Int,
  family : Int,
  socktype : Int,
  protocol : Int
) -> AddrInfoHints = "moonbit_uv_addrinfo_hints"

///|
type AddrInfoFlags Int

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
  passive~ : Bool = false,
  canonname~ : Bool = false,
  numeric_host~ : Bool = false,
  numeric_serv~ : Bool = false,
  all~ : Bool = false,
  addrconfig~ : Bool = false,
  v4mapped~ : Bool = false
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
  socktype? : SockType,
  protocol? : Protocol
) -> AddrInfoHints {
  let flags = match flags {
    Some(flags) => flags._
    None => 0
  }
  let family = match family {
    Some(family) => family.to_int()
    None => _AF_UNSPEC
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
#borrow(self, cb)
extern "c" fn uv_addrinfo_results_iterate(
  self : AddrInfoResults,
  cb : (Int, Int, Int, Int, Sockaddr, @c.Pointer[Byte]) -> Bool
) -> Bool = "moonbit_uv_addrinfo_results_iterate"

///|
extern "c" fn uv_SOCK_STREAM() -> Int = "moonbit_uv_SOCK_STREAM"

///|
let _SOCK_STREAM : Int = uv_SOCK_STREAM()

///|
extern "c" fn uv_SOCK_DGRAM() -> Int = "moonbit_uv_SOCK_DGRAM"

///|
let _SOCK_DGRAM : Int = uv_SOCK_DGRAM()

///|
extern "c" fn uv_SOCK_RAW() -> Int = "moonbit_uv_SOCK_RAW"

///|
let _SOCK_RAW : Int = uv_SOCK_RAW()

///|
extern "c" fn uv_IPPROTO_UDP() -> Int = "moonbit_uv_IPPROTO_UDP"

///|
let _IPPROTO_UDP : Int = uv_IPPROTO_UDP()

///|
extern "c" fn uv_IPPROTO_TCP() -> Int = "moonbit_uv_IPPROTO_TCP"

///|
let _IPPROTO_TCP : Int = uv_IPPROTO_TCP()

///|
extern "c" fn uv_IF_NAMESIZE() -> Int = "moonbit_uv_IF_NAMESIZE"

///|
let _IF_NAMESIZE : Int = uv_IF_NAMESIZE()

///|
#borrow(src, dst)
extern "c" fn uv_ip_name(src : Sockaddr, dst : Bytes) -> Int = "moonbit_uv_ip_name"

///|
pub fn ip_name(self : Sockaddr) -> String!Errno {
  let bytes = Bytes::make(_IF_NAMESIZE, 0)
  let status = uv_ip_name(self, bytes)
  if status < 0 {
    raise Errno::of_int(status)
  }
  let buffer = @buffer.new()
  for i = 0; bytes[i] != 0; i = i + 1 {
    buffer.write_byte(bytes[i])
  }
  return @encoding.decode_lossy(encoding=UTF8, buffer.contents())
}

///|
struct AddrInfo {
  family : Int
  socktype : Int
  protocol : Int
  addr : Sockaddr
  canonname : String?
}

///|
extern "c" fn uv_AF_INET() -> Int = "moonbit_uv_AF_INET"

///|
let _AF_INET : Int = uv_AF_INET()

///|
extern "c" fn uv_AF_INET6() -> Int = "moonbit_uv_AF_INET6"

///|
let _AF_INET6 : Int = uv_AF_INET6()

///|
extern "c" fn uv_AF_UNSPEC() -> Int = "moonbit_uv_AF_UNSPEC"

///|
let _AF_UNSPEC : Int = uv_AF_UNSPEC()

///|
pub enum AddressFamily {
  INET
  INET6
} derive(Show)

///|
pub fn AddressFamily::inet() -> AddressFamily {
  return INET
}

///|
pub fn AddressFamily::inet6() -> AddressFamily {
  return INET6
}

///|
fn AddressFamily::of_int(self : Int) -> AddressFamily!Errno {
  if self == _AF_INET {
    return INET
  }
  if self == _AF_INET6 {
    return INET6
  }
  raise Errno(EINVAL)
}

///|
fn AddressFamily::to_int(self : AddressFamily) -> Int {
  match self {
    INET => _AF_INET
    INET6 => _AF_INET6
  }
}

///|
pub fn AddrInfo::family(self : AddrInfo) -> AddressFamily!Errno {
  AddressFamily::of_int!(self.family)
}

///|
pub fn AddrInfo::addr(self : AddrInfo) -> Sockaddr {
  self.addr
}

///|
enum SockType {
  STREAM
  RAW
  DGRAM
} derive(Show)

///|
pub fn SockType::stream() -> SockType {
  return STREAM
}

///|
pub fn SockType::raw() -> SockType {
  return RAW
}

///|
pub fn SockType::dgram() -> SockType {
  return DGRAM
}

///|
fn SockType::of_int(self : Int) -> SockType!Errno {
  if self == _SOCK_STREAM {
    return STREAM
  }
  if self == _SOCK_RAW {
    return RAW
  }
  if self == _SOCK_DGRAM {
    return DGRAM
  }
  raise Errno(EINVAL)
}

///|
fn SockType::to_int(self : SockType) -> Int {
  match self {
    STREAM => _SOCK_STREAM
    RAW => _SOCK_RAW
    DGRAM => _SOCK_DGRAM
  }
}

///|
pub fn AddrInfo::socktype(self : AddrInfo) -> SockType!Errno {
  return SockType::of_int!(self.socktype)
}

///|
pub enum Protocol {
  TCP
  UDP
} derive(Show)

///|
pub fn Protocol::tcp() -> Protocol {
  return TCP
}

///|
pub fn Protocol::udp() -> Protocol {
  return UDP
}

///|
fn Protocol::of_int(self : Int) -> Protocol!Errno {
  if self == _IPPROTO_TCP {
    return TCP
  }
  if self == _IPPROTO_UDP {
    return UDP
  }
  raise Errno(EINVAL)
}

///|
fn Protocol::to_int(self : Protocol) -> Int {
  match self {
    TCP => _IPPROTO_TCP
    UDP => _IPPROTO_UDP
  }
}

///|
pub fn AddrInfo::protocol(self : AddrInfo) -> Protocol!Errno {
  Protocol::of_int!(self.protocol)
}

///|
pub fn AddrInfo::canonname(self : AddrInfo) -> String? {
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
        canonname
      ) {
        let canonname = if canonname.is_null() {
          None
        } else {
          let buffer = @buffer.new()
          for i = 0; canonname[i] != 0; i = i + 1 {
            buffer.write_byte(canonname[i])
          }
          Some(@encoding.decode_lossy(encoding=UTF8, buffer.contents()))
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
extern "c" fn uv_getaddrinfo(
  self : Loop,
  req : GetAddrInfo,
  getaddrinfo_cb : (GetAddrInfo, Int, AddrInfoResults) -> Unit,
  node : Bytes,
  service : Bytes,
  hints : AddrInfoHints
) -> Int = "moonbit_uv_getaddrinfo"

///|
pub fn[Node : ToNtbs, Service : ToNtbs] getaddrinfo(
  self : Loop,
  getaddrinfo_cb : (GetAddrInfo, Iter[AddrInfo]) -> Unit,
  error_cb : (GetAddrInfo, Errno) -> Unit,
  node : Node,
  service : Service,
  hints? : AddrInfoHints
) -> Unit!Errno {
  fn uv_cb(req : GetAddrInfo, status : Int, addrinfo : AddrInfoResults) {
    if status < 0 {
      error_cb(req, Errno::of_int(status))
    } else {
      getaddrinfo_cb(req, addrinfo.iter())
    }
  }

  let req = uv_getaddrinfo_make()
  let status = uv_getaddrinfo(
    self,
    req,
    uv_cb,
    node.to_ntbs(),
    service.to_ntbs(),
    hints.or_else(AddrInfoHints::nil),
  )
  if status < 0 {
    raise Errno::of_int(status)
  }
}
