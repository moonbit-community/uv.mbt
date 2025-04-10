///|
type SockaddrIn Bytes

///|
extern "c" fn sockaddr_in_make() -> SockaddrIn = "moonbit_uv_sockaddr_in_make"

///|
extern type SockaddrIn6

///|
extern type Tcp

///|
pub fn Tcp::to_stream(self : Tcp) -> Stream = "%identity"

///|
pub fn Tcp::to_handle(self : Tcp) -> Handle = "%identity"

///|
pub extern "c" fn tcp_alloc() -> Tcp = "moonbit_uv_tcp_alloc"

///|
pub extern "c" fn tcp_init(loop_ : Loop, tcp : Tcp) -> Int = "moonbit_uv_tcp_init"

///|
pub extern "c" fn ip4_addr(ip : Bytes, port : Int, addr : SockaddrIn) -> Unit = "moonbit_uv_ip4_addr"

///|
pub extern "c" fn ip6_addr(ip : Bytes, port : Int, addr : SockaddrIn6) -> Unit = "moonbit_uv_ip6_addr"

///|
extern type Sockaddr

///|
pub fn SockaddrIn::to_sockaddr(addr : SockaddrIn) -> Sockaddr = "%identity"

///|
pub extern "c" fn tcp_bind(tcp : Tcp, addr : Sockaddr, flags : Int) -> Int = "moonbit_uv_tcp_bind"

///|
pub extern "c" fn listen(
  stream : Stream,
  backlog : Int,
  cb : (Stream, Int) -> Unit
) -> Int = "moonbit_uv_listen"

///|
pub extern "c" fn accept(server : Stream, client : Stream) -> Int = "moonbit_uv_accept"

///|
type Connect Bytes

///|
pub fn Connect::to_req(self : Connect) -> Req = "%identity"

///|
pub extern "c" fn connect_alloc() -> Connect = "moonbit_uv_connect_alloc"

///|
pub extern "c" fn tcp_connect(
  req : Connect,
  handle : Tcp,
  addr : Sockaddr,
  cb : (Connect, Int) -> Unit
) -> Int = "moonbit_uv_tcp_connect"
