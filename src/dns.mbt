///|
type GetAddrInfo

///|
type GetNameInfo

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
type AddrInfoResults

///|
extern "c" fn uv_addrinfo_results_iter(
  addrinfo : AddrInfoResults,
  cb : (Int, Int, Int, Int, Sockaddr, @c.Pointer[Byte]) -> Bool
) -> Bool = "moonbit_uv_addrinfo_results_iter"

///|
extern "c" fn uv_freeaddrinfo(addrinfo : AddrInfoResults) = "uv_freeaddrinfo"

///|
extern "c" fn uv_SOCK_STREAM() -> Int = "uv_SOCK_STREAM"

///|
extern "c" fn uv_SOCK_DGRAM() -> Int = "uv_SOCK_DGRAM"

///|
extern "c" fn uv_SOCK_RAW() -> Int = "uv_SOCK_RAW"

///|
extern "c" fn uv_IPPROTO_UDP() -> Int = "uv_IPPROTO_UDP"

///|
extern "c" fn uv_IPPROTO_TCP() -> Int = "uv_IPPROTO_TCP"

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
extern "c" fn uv_AF_INET() -> Int = "uv_AF_INET"

///|
extern "c" fn uv_AF_INET6() -> Int = "uv_AF_INET6"

///|
pub enum AddressFamily {
  IPv4
  IPv6
}

///|
pub fn AddrInfo::family(self : AddrInfo) -> AddressFamily! {
  if self.family == uv_AF_INET() {
    AddressFamily::IPv4
  } else if self.family == uv_AF_INET6() {
    AddressFamily::IPv6
  } else {
    fail!("Unknown address family")
  }
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
