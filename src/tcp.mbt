///|
extern type SockaddrIn

///|
pub extern "c" fn sockaddr_in_alloc() -> SockaddrIn = "moonbit_uv_sockaddr_in_alloc"

///|
extern type SockaddrIn6

///|
extern type Tcp

///|
pub impl ToStream for Tcp with to_stream(self : Tcp) -> Stream {
  identity(self)
}

///|
pub impl ToHandle for Tcp with to_handle(self : Tcp) -> Handle {
  identity(self)
}

///|
pub extern "c" fn tcp_alloc() -> Tcp = "moonbit_uv_tcp_alloc"

///|
pub extern "c" fn tcp_init(loop_ : Loop, tcp : Tcp) -> Int = "moonbit_uv_tcp_init"

///|
pub extern "c" fn ip4_addr(ip : Bytes, port : Int, addr : SockaddrIn) -> Unit = "moonbit_uv_ip4_addr"

///|
pub extern "c" fn ip6_addr(ip : Bytes, port : Int, addr : SockaddrIn6) -> Unit = "moonbit_uv_ip6_addr"

///|
pub extern "c" fn tcp_bind(tcp : Tcp, addr : SockaddrIn, flags : Int) -> Int = "moonbit_uv_tcp_bind"

///|
pub extern "c" fn listen(
  stream : Stream,
  backlog : Int,
  cb : (Stream, Int) -> Unit
) -> Int = "moonbit_uv_listen"

///|
pub extern "c" fn accept(server : Stream, client : Stream) -> Int = "moonbit_uv_accept"
