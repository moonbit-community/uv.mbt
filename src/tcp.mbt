///|
type SockaddrIn Bytes

///|
extern "c" fn uv_sockaddr_in_make() -> SockaddrIn = "moonbit_uv_sockaddr_in_make"

///|
type Tcp

///|
pub impl ToHandle for Tcp with to_handle(self : Tcp) -> Handle = "%identity"

///|
pub impl ToHandle for Tcp with of_handle(self : Handle) -> Tcp = "%identity"

///|
pub impl ToStream for Tcp with to_stream(self : Tcp) -> Stream = "%identity"

///|
pub impl ToStream for Tcp with of_stream(self : Stream) -> Tcp = "%identity"

///|
extern "c" fn uv_tcp_make() -> Tcp = "moonbit_uv_tcp_make"

///|
extern "c" fn uv_tcp_init(self : Loop, tcp : Tcp) -> Int = "moonbit_uv_tcp_init"

///|
pub fn Tcp::new(loop_ : Loop) -> Tcp!Errno {
  let tcp = uv_tcp_make()
  let result = uv_tcp_init(loop_, tcp)
  if result < 0 {
    raise Errno::of_int(result)
  }
  tcp
}

///|
extern "c" fn uv_ip4_addr(ip : Bytes, port : Int, addr : SockaddrIn) = "moonbit_uv_ip4_addr"

///|
pub fn ip4_addr[Ntbs : ToNtbs](ip : Ntbs, port : Int) -> SockaddrIn {
  let ip = ip.to_ntbs()
  let addr = uv_sockaddr_in_make()
  uv_ip4_addr(ip, port, addr)
  addr
}

///|
type Sockaddr Bytes

///|
pub impl ToSockaddr for Sockaddr with to_sockaddr(self : Sockaddr) -> Sockaddr = "%identity"

///|
pub impl ToSockaddr for SockaddrIn with to_sockaddr(addr : SockaddrIn) -> Sockaddr = "%identity"

///|
extern "c" fn uv_tcp_bind(tcp : Tcp, addr : Sockaddr, flags : UInt) -> Int = "moonbit_uv_tcp_bind"

///|
type TcpBindFlags UInt

///|
const TCP_IPV6ONLY : UInt = 1

///|
const TCP_REUSEPORT : UInt = 2

///|
pub fn TcpBindFlags::new(
  ipv6_only~ : Bool = false,
  reuse_port~ : Bool = false
) -> TcpBindFlags {
  let mut flags = 0U
  if ipv6_only {
    flags = flags | TCP_IPV6ONLY
  }
  if reuse_port {
    flags = flags | TCP_REUSEPORT
  }
  return flags
}

///|
pub fn Tcp::bind[Sockaddr : ToSockaddr](
  self : Tcp,
  addr : Sockaddr,
  flags : TcpBindFlags
) -> Unit!Errno {
  let status = uv_tcp_bind(self, addr.to_sockaddr(), flags._)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_listen(
  stream : Stream,
  backlog : Int,
  cb : (Stream, Int) -> Unit
) -> Int = "moonbit_uv_listen"

///|
pub fn listen[Stream : ToStream](
  stream : Stream,
  backlog : Int,
  connection_cb : (Stream) -> Unit,
  error_cb : (Stream, Errno) -> Unit
) -> Unit!Errno {
  stream.listen!(backlog, connection_cb, error_cb)
}

///|
impl ToStream with listen(self, backlog, connection_cb, error_cb) {
  fn uv_cb(self : Stream, status : Int) {
    if status < 0 {
      error_cb(ToStream::of_stream(self), Errno::of_int(status))
    } else {
      connection_cb(ToStream::of_stream(self))
    }
  }

  let status = uv_listen(self.to_stream(), backlog, uv_cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_accept(server : Stream, client : Stream) -> Int = "moonbit_uv_accept"

///|
pub fn accept[Server : ToStream, Client : ToStream](
  server : Server,
  client : Client
) -> Unit!Errno {
  let status = uv_accept(server.to_stream(), client.to_stream())
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
type Connect Bytes

///|
pub impl ToReq for Connect with to_req(self : Connect) -> Req = "%identity"

///|
extern "c" fn uv_connect_make() -> Connect = "moonbit_uv_connect_make"

///|
extern "c" fn uv_tcp_connect(
  req : Connect,
  handle : Tcp,
  addr : Sockaddr,
  cb : (Connect, Int) -> Unit
) -> Int = "moonbit_uv_tcp_connect"

///|
trait ToSockaddr {
  to_sockaddr(self : Self) -> Sockaddr
}

///|
pub fn Tcp::connect[Sockaddr : ToSockaddr](
  self : Tcp,
  addr : Sockaddr,
  connect_cb : (Connect) -> Unit,
  error_cb : (Connect, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Connect, status : Int) {
    if status < 0 {
      error_cb(req, Errno::of_int(status))
    } else {
      connect_cb(req)
    }
  }

  let req = uv_connect_make()
  let status = uv_tcp_connect(req, self, addr.to_sockaddr(), cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
