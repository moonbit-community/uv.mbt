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
  read_cb : (Stream, Int64, Bytes?, Int, Int) -> Unit
) -> Int = "moonbit_uv_read_start"

///|
pub fn Stream::read_start(
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
    buf_data : Bytes?,
    buf_offset : Int,
    buf_length : Int
  ) -> Unit {
    if nread < 0 {
      error_cb(stream, Errno::of_int(nread.to_int()))
    } else {
      read_cb(stream, nread.to_int(), buf_data.unwrap()[buf_offset:buf_length])
    }
  }

  let result = uv_read_start(self, uv_alloc_cb, uv_read_cb)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
pub fn read_start[Stream : ToStream](
  stream : Stream,
  alloc_cb : (Stream, Int) -> @bytes.View,
  read_cb : (Stream, Int, @bytes.View) -> Unit,
  error_cb : (Stream, Errno) -> Unit
) -> Unit!Errno {
  stream.read_start!(alloc_cb, read_cb, error_cb)
}

///|
extern "c" fn uv_read_stop(stream : Stream) -> Int = "moonbit_uv_read_stop"

///|
pub fn Stream::read_stop(self : Stream) -> Unit!Errno {
  let result = uv_read_stop(self)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
pub fn read_stop[Stream : ToStream](stream : Stream) -> Unit!Errno {
  stream.read_stop!()
}

///|
type Write

///|
pub impl ToReq for Write with to_req(self : Write) -> Req = "%identity"

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
pub fn Stream::write(
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
pub fn write[Stream : ToStream](
  stream : Stream,
  bufs : Array[@bytes.View],
  write_cb : (Write) -> Unit,
  error_cb : (Write, Errno) -> Unit
) -> Unit!Errno {
  stream.write!(bufs, write_cb, error_cb)
}

///|
pub trait ToStream: ToHandle {
  to_stream(Self) -> Stream
  of_stream(Stream) -> Self
  read_start(
    Self,
    (Self, Int) -> @bytes.View,
    (Self, Int, @bytes.View) -> Unit,
    (Self, Errno) -> Unit,
  ) -> Unit!Errno = _
  read_stop(Self) -> Unit!Errno = _
  write(Self, Array[@bytes.View], (Write) -> Unit, (Write, Errno) -> Unit) ->
       Unit!Errno = _
  listen(Self, Int, (Self) -> Unit, (Self, Errno) -> Unit) -> Unit!Errno = _
  is_readable(Self) -> Bool = _
  is_writable(Self) -> Bool = _
  shutdown(Self, (Shutdown) -> Unit, (Shutdown, Errno) -> Unit) -> Unit!Errno = _
}

///|
pub impl ToStream for Stream with to_stream(self) = "%identity"

///|
pub impl ToStream for Stream with of_stream(self) = "%identity"

///|
impl ToStream with read_start(self, alloc_cb, read_cb, error_cb) {
  // We are wrapping callbacks here, for two reasons:
  // 1. We need to downcast the `Handle`/`Stream` to concrete types.
  // 2. (Mutually) recursive indirect call will create a reference loop,
  //    and RC will fail to collect it. Therefore, instead of directly
  //    passing `alloc_cb`, `read_cb` and `error_cb` to `read_start()`,
  //    we wrap them into local functions, so that compiler can perform
  //    capture analysis and will not create closures that refer to each
  //    other.
  fn handle_alloc_cb(handle : Handle, suggested_size : Int) {
    alloc_cb(ToHandle::of_handle(handle), suggested_size)
  }

  fn stream_read_cb(stream : Stream, count : Int, bytes : @bytes.View) {
    read_cb(ToStream::of_stream(stream), count, bytes)
  }

  fn stream_error_cb(stream : Stream, errno : Errno) {
    error_cb(ToStream::of_stream(stream), errno)
  }

  self.to_stream().read_start!(handle_alloc_cb, stream_read_cb, stream_error_cb)
}

///|
impl ToStream with read_stop(self) {
  self.to_stream().read_stop!()
}

///|
impl ToStream with write(self, bufs, write_cb, error_cb) {
  self.to_stream().write!(bufs, write_cb, error_cb)
}

///|
extern "c" fn uv_is_readable(stream : Stream) -> Bool = "moonbit_uv_is_readable"

///|
extern "c" fn uv_is_writable(stream : Stream) -> Bool = "moonbit_uv_is_writable"

///|
pub fn Stream::is_readable(self : Stream) -> Bool {
  uv_is_readable(self)
}

///|
pub fn Stream::is_writable(self : Stream) -> Bool {
  uv_is_writable(self)
}

///|
pub fn is_readable[Stream : ToStream](stream : Stream) -> Bool {
  uv_is_readable(stream.to_stream())
}

///|
pub fn is_writable[Stream : ToStream](stream : Stream) -> Bool {
  uv_is_writable(stream.to_stream())
}

///|
impl ToStream with is_readable(self) {
  self.to_stream().is_readable()
}

///|
impl ToStream with is_writable(self) {
  self.to_stream().is_writable()
}

///|
type Shutdown

///|
pub impl ToReq for Shutdown with to_req(self : Shutdown) -> Req = "%identity"

///|
extern "c" fn uv_shutdown_make() -> Shutdown = "moonbit_uv_shutdown_make"

///|
extern "c" fn uv_shutdown(
  shutdown : Shutdown,
  handle : Stream,
  cb : (Shutdown, Int) -> Unit
) -> Int = "moonbit_uv_shutdown"

///|
pub fn Stream::shutdown(
  self : Stream,
  shutdown_cb : (Shutdown) -> Unit,
  error_cb : (Shutdown, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Shutdown, status : Int) {
    if status < 0 {
      error_cb(req, Errno::of_int(status))
    } else {
      shutdown_cb(req)
    }
  }

  let req = uv_shutdown_make()
  let result = uv_shutdown(req, self, cb)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
pub fn shutdown[Stream : ToStream](
  stream : Stream,
  shutdown_cb : (Shutdown) -> Unit,
  error_cb : (Shutdown, Errno) -> Unit
) -> Unit!Errno {
  stream.shutdown!(shutdown_cb, error_cb)
}

///|
impl ToStream with shutdown(self, shutdown_cb, error_cb) {
  self.to_stream().shutdown!(shutdown_cb, error_cb)
}
