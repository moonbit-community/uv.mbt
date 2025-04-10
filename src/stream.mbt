///|
type Stream

///|
pub fn Stream::to_handle(self : Stream) -> Handle = "%identity"

///|
pub impl ToHandle for Stream with to_handle(self) {
  self.to_handle()
}

///|
pub impl ToHandle for Stream with of_handle(self) = "%identity"

///|
extern "c" fn uv_read_start(
  stream : Stream,
  alloc_cb : (Handle, UInt64, @c.Pointer[Int], @c.Pointer[Int]) -> Bytes,
  read_cb : (Stream, Int64, Bytes, Int, Int) -> Unit
) -> Int = "moonbit_uv_read_start"

///|
pub fn read_start(
  self : Stream,
  alloc_cb : (Handle, Int) -> @bytes.View,
  read_cb : (Stream, Int, @bytes.View) -> Unit,
  error_cb : (Stream, Errno) -> Unit
) -> Unit!Errno {
  fn uv_alloc_cb(
    handle : Handle,
    suggested_size : UInt64,
    buf_offset : @c.Pointer[Int],
    buf_length : @c.Pointer[Int]
  ) -> Bytes {
    let bytes = alloc_cb(handle, suggested_size.to_int())
    buf_offset[0] = bytes.start_offset()
    buf_length[0] = bytes.length()
    return bytes.data()
  }

  fn uv_read_cb(
    stream : Stream,
    nread : Int64,
    buf_data : Bytes,
    buf_offset : Int,
    buf_length : Int
  ) -> Unit {
    if nread < 0 {
      error_cb(stream, Errno::of_int(nread.to_int()))
    } else {
      read_cb(stream, nread.to_int(), buf_data[buf_offset:buf_length])
    }
  }

  let result = uv_read_start(self, uv_alloc_cb, uv_read_cb)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
extern "c" fn uv_read_stop(stream : Stream) -> Int = "moonbit_uv_read_stop"

///|
pub fn read_stop(self : Stream) -> Unit!Errno {
  let result = uv_read_stop(self)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
type Write

///|
pub fn Write::to_req(self : Write) -> Req = "%identity"

///|
extern "c" fn uv_write_make() -> Write = "moonbit_uv_write_make"

///|
extern "c" fn uv_write(
  write : Write,
  handle : Stream,
  bufs_base : FixedArray[Bytes],
  bufs_offset : FixedArray[Int],
  bufs_length : FixedArray[Int],
  cb : (Write, Int) -> Unit
) -> Int = "moonbit_uv_write"

///|
pub fn write(
  self : Stream,
  bufs : Array[@bytes.View],
  write_cb : (Write) -> Unit,
  error_cb : (Write, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Write, status : Int) {
    if status < 0 {
      error_cb(req, Errno::of_int(status))
    } else {
      write_cb(req)
    }
  }

  let req = uv_write_make()
  let bufs_size = bufs.length()
  let bufs_base : FixedArray[Bytes] = FixedArray::make(bufs_size, [])
  let bufs_offset = FixedArray::make(bufs_size, 0)
  let bufs_length = FixedArray::make(bufs_size, 0)
  for i in 0..<bufs.length() {
    bufs_base[i] = bufs[i].data()
    bufs_offset[i] = bufs[i].start_offset()
    bufs_length[i] = bufs[i].length()
  }
  let result = uv_write(req, self, bufs_base, bufs_offset, bufs_length, cb)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
pub trait ToStream: ToHandle {
  to_stream(Self) -> Stream
  read_start(
    Self,
    (Handle, Int) -> @bytes.View,
    (Stream, Int, @bytes.View) -> Unit,
    (Stream, Errno) -> Unit,
  ) -> Unit!Errno
  read_stop(Self) -> Unit!Errno
}

///|
impl ToStream with read_start(self, alloc_cb, read_cb, error_cb) {
  self.to_stream().read_start!(alloc_cb, read_cb, error_cb)
}

///|
impl ToStream with read_stop(self) {
  self.to_stream().read_stop!()
}
