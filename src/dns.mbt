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
pub fn AddrInfoHints::new(
  flags~ : Int = 0,
  family~ : Int = 0,
  socktype~ : Int = 0,
  protocol~ : Int = 0
) -> AddrInfoHints {
  uv_addrinfo_hints(flags, family, socktype, protocol)
}

///|
extern "c" fn AddrInfoHints::nil() -> AddrInfoHints = "moonbit_c_null"

///|
priv type AddrInfoResults

///|
extern "c" fn uv_addrinfo_results_iter(
  self : AddrInfoResults,
  cb : (Int, Int, Int, Int, Sockaddr, @c.Pointer[Byte]) -> Bool
) -> Bool = "moonbit_uv_addrinfo_results_iter"

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
  return @encoding.decoder(UTF8).decode_lossy(buffer.contents())
}

///|
struct AddrInfo {
  flags : Int
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
  IPv4
  IPv6
  Unspecified
} derive(Show)

///|
fn AddressFamily::of_int(self : Int) -> AddressFamily!Errno {
  if self == _AF_INET {
    return IPv4
  }
  if self == _AF_INET6 {
    return IPv6
  }
  if self == _AF_UNSPEC {
    return Unspecified
  }
  raise Errno(EINVAL)
}

///|
pub fn AddrInfo::family(self : AddrInfo) -> AddressFamily!Errno {
  AddressFamily::of_int!(self.family)
}

///|
pub fn AddrInfo::flags(self : AddrInfo) -> Int {
  self.flags
}

///|
pub fn AddrInfo::addr(self : AddrInfo) -> Sockaddr {
  self.addr
}

///|
enum SockType {
  Stream
  Raw
  Datagram
} derive(Show)

///|
pub fn SockType::of_int(self : Int) -> SockType!Errno {
  if self == _SOCK_STREAM {
    return Stream
  }
  if self == _SOCK_RAW {
    return Raw
  }
  if self == _SOCK_DGRAM {
    return Datagram
  }
  raise Errno(EINVAL)
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
    if uv_addrinfo_results_iter(self, fn(
        flags,
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
          Some(@encoding.decoder(UTF8).decode_lossy(buffer.contents()))
        }
        match yield_({ flags, family, socktype, protocol, addr, canonname }) {
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
pub fn getaddrinfo[Node : ToNtbs, Service : ToNtbs](
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
