///|
extern type Stream

///|
pub trait ToStream {
  to_stream(Self) -> Stream
}

///|
pub impl ToHandle for Stream with to_handle(self : Stream) -> Handle = "%identity"

///|
pub extern "c" fn read_start(
  stream : Stream,
  alloc_cb : (Handle, UInt64, Buf) -> Unit,
  read_cb : (Stream, Int64, Buf) -> Unit
) -> Int = "moonbit_uv_read_start"

///|
pub extern "c" fn read_stop(stream : Stream) -> Int = "moonbit_uv_read_stop"

///|
pub async fn Stream::read(self : Stream) -> @bytes.View!Errno {
  async_suspend_with_error!!(fn(resolve, reject) {
    let alloc_cb = fn(_, n : UInt64, buf) {
      let bytes = Bytes::make(n.to_int(), (0 : Byte))
      buf_init(buf, bytes, 0, bytes.length())
    }
    let read_cb = fn(_, n : Int64, buf) {
      read_stop(self) |> ignore()
      if n < 0 {
        reject(Errno(n.to_int()))
      } else {
        resolve(buf_get(buf)[:n.to_int()])
      }
    }
    let status = read_start(self, alloc_cb, read_cb)
    if status < 0 {
      reject(Errno(status))
    }
  })
}

///|
extern type Write

///|
pub extern "c" fn write_alloc() -> Write = "moonbit_uv_write_alloc"

///|
pub extern "c" fn write(
  write : Write,
  handle : Stream,
  bufs : FixedArray[Buf],
  cb : (Write, Int) -> Unit
) -> Int = "moonbit_uv_write"

///|
pub async fn Stream::write(
  self : Stream,
  bytes : @bytes.View
) -> @bytes.View!Errno {
  async_suspend_with_error!!(fn(resolve, reject) {
    let buf = buf_alloc()
    let bytes = BytesView::of(bytes)
    buf_init(buf, bytes.bytes, bytes.start, bytes.len - bytes.start)
    let bufs : FixedArray[Buf] = [buf]
    let write_cb = fn(_, status) {
      if status < 0 {
        reject(Errno(status))
      } else {
        resolve(bytes.to()[:status])
      }
    }
    let req = write_alloc()
    let status = write(req, self, bufs, write_cb)
    if status < 0 {
      reject(Errno(status))
    }
  })
}

///|
pub async fn Stream::listen(self : Stream, backlog : Int) -> Unit!Errno {
  async_suspend_with_error!!(fn(resolve, reject) {
    let result = listen(self, backlog, fn(_, status) {
      if status < 0 {
        reject(Errno(status))
      } else {
        resolve(())
      }
    })
    if result < 0 {
      reject(Errno(result))
    }
  })
}
