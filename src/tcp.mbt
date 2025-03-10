///|
extern type SockaddrIn

///|
pub extern "c" fn sockaddr_in_alloc() -> SockaddrIn = "moonbit_uv_sockaddr_in_alloc"

///|
extern type SockaddrIn6

///|
extern type Tcp

///|
pub impl ToStream for Tcp with to_stream(self : Tcp) -> Stream = "%identity"

///|
pub impl ToHandle for Tcp with to_handle(self : Tcp) -> Handle = "%identity"

///|
pub extern "c" fn tcp_alloc() -> Tcp = "moonbit_uv_tcp_alloc"

///|
pub extern "c" fn tcp_init(loop_ : Loop, tcp : Tcp) -> Int = "moonbit_uv_tcp_init"

///|
pub fn Tcp::new(loop_ : Loop) -> Tcp!Errno {
  let tcp = tcp_alloc()
  tcp_init(loop_, tcp) |> errno!()
  tcp
}

///|
pub fn Loop::tcp(self : Loop) -> Tcp!Errno {
  let tcp = tcp_alloc()
  tcp_init(self, tcp) |> errno!()
  tcp
}

///|
extern "c" fn ip4_addr_bytes(
  ip : Bytes,
  port : Int,
  addr : SockaddrIn
) -> Unit = "moonbit_uv_ip4_addr"

///|
pub fn ip4_addr(ip : String, port : Int) -> SockaddrIn {
  let ip : Bytes = [..@encoding.encode(UTF8, ip), b'\x00']
  let sockaddr = sockaddr_in_alloc()
  ip4_addr_bytes(ip, port, sockaddr)
  sockaddr
}

///|
pub extern "c" fn ip6_addr(ip : Bytes, port : Int, addr : SockaddrIn6) -> Unit = "moonbit_uv_ip6_addr"

///|
pub extern "c" fn tcp_bind(tcp : Tcp, addr : SockaddrIn, flags : Int) -> Int = "moonbit_uv_tcp_bind"

pub fn Tcp::bind(self : Tcp, sockaddr : SockaddrIn, flags : Int) -> Unit!Errno {
  tcp_bind(self, sockaddr, flags) |> errno!()
}

///|
pub extern "c" fn listen(
  stream : Stream,
  backlog : Int,
  cb : (Stream, Int) -> Unit
) -> Int = "moonbit_uv_listen"

pub async fn Tcp::listen(self : Tcp, backlog : Int) -> Unit!Errno {
  self.to_stream().listen!!(backlog)
}

///|
pub extern "c" fn accept(server : Stream, client : Stream) -> Int = "moonbit_uv_accept"
