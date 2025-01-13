///|
fn run_async[T](f :  async() -> T) = "%async.run"

///|
async fn suspend[T](f : ((T) -> Unit) -> Unit) -> T = "%async.suspend"

///|
async fn fs_open(
  loop_ : @uv.Loop,
  path : Bytes,
  flags : Int,
  mode : Int
) -> @uv.File {
  let req = @uv.fs_alloc()
  suspend!!(fn(k) {
    @uv.fs_open(loop_, req, path, flags, mode, fn(req) {
      k(@uv.fs_get_result(req))
    })
    |> ignore
  })
}

///|
async fn fs_read(
  loop_ : @uv.Loop,
  file : @uv.File,
  bufs : FixedArray[@uv.Buf],
  offset : Int64
) -> Int64 {
  let req = @uv.fs_alloc()
  suspend!!(fn(k) {
    @uv.fs_read(loop_, req, file, bufs, offset, fn(req) {
      k(@uv.fs_get_result(req))
    })
    |> ignore
  })
}

///|
async fn fs_write(
  loop_ : @uv.Loop,
  file : @uv.File,
  bufs : FixedArray[@uv.Buf],
  offset : Int64
) -> Int64 {
  let req = @uv.fs_alloc()
  suspend!!(fn(k) {
    @uv.fs_write(loop_, req, file, bufs, offset, fn(req) {
      k(@uv.fs_get_result(req))
    })
    |> ignore
  })
}

///|
async fn close(loop_ : @uv.Loop, file : @uv.File) -> Unit {
  let req = @uv.fs_alloc()
  suspend!!(fn(k) {
    @uv.fs_close(loop_, req, file, fn(_req) { k(()) }) |> ignore
  })
}

///|
async fn ip4_addr(ip : Bytes, port : Int) -> @uv.SockaddrIn {
  let addr = @uv.sockaddr_in_alloc()
  suspend!!(fn(k) {
    @uv.ip4_addr(ip, port, addr) |> ignore
    k(addr)
  })
}

///|
fn tcp_init(loop_ : @uv.Loop) -> @uv.Tcp {
  let tcp = @uv.tcp_alloc()
  @uv.tcp_init(loop_, tcp) |> ignore
  tcp
}

///|
async fn listen(stream : @uv.Stream, backlog : Int) -> Int {
  suspend!!(fn(k) {
    @uv.listen(stream, backlog, fn(_stream, status) { k(status) }) |> ignore
  })
}

///|
async fn read_start(stream : @uv.Stream) -> (Int64, @uv.Buf) {
  suspend!!(fn(k) {
    let alloc_cb = fn(_handle, n : UInt64, buf) {
      @uv.buf_init(buf, FixedArray::make(n.to_int(), (0 : Byte))) |> ignore
    }
    let read_cb = fn(_stream, n : Int64, buf) { k((n, buf)) }
    @uv.read_start(stream, alloc_cb, read_cb) |> ignore
  })
}

///|
async fn write(stream : @uv.Stream, bufs : FixedArray[@uv.Buf]) -> Int {
  suspend!!(fn(k) {
    let write = @uv.write_alloc()
    @uv.write(write, stream, bufs, fn(_write, status) { k(status) }) |> ignore
  })
}

///|
fn identity[T, U](x : T) -> U = "%identity"

///|
fn main {
  try {
    @async.run!(fn(loop_) {
      let server = loop_.tcp!()
      let addr = ip4_addr!!(b"0.0.0.0", 12345)
      server.bind!(addr, 0)
      println("listening")
      let status = server.listen!!(128)
      println("listen status: \{status}")
      while true {
        let client = server.accept!()
        println("accept succeed")
        loop read_start!!(client.to_stream()) {
          (nread, buf) => {
            println("nread: \{nread}")
            @uv.buf_set_len(buf, nread.reinterpret_as_uint64())
            let bufs : FixedArray[@uv.Buf] = FixedArray::make(1, 0L) |> identity
            bufs[0] = buf
            write!!(client.to_stream(), bufs) |> ignore
            continue read_start!!(client.to_stream())
          }
        }
      }
    })
  } catch {
    @async.Errno(_) as errno => println("Error: \{errno}")
    error => println("Errno: \{error}")
  }
}
