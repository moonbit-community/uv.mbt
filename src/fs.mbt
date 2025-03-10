///|
extern type Fs

///|
struct File {
  self : Loop
  file : File_
}

///|
impl ToReq for Fs with to_req(self : Fs) -> Req = "%identity"

///|
extern "c" fn fs_alloc() -> Fs = "moonbit_uv_fs_alloc"

///|
pub(all) enum OpenFlag {
  ReadOnly = 0x0
  WriteOnly = 0x1
  ReadWrite = 0x2
}

///|
extern "c" fn fs_open(
  loop_ : Loop,
  req : Fs,
  path : Bytes,
  flags : OpenFlag,
  mode : Int,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_open"

///|
pub async fn Loop::open(
  self : Loop,
  path : String,
  flags : OpenFlag,
  mode : Int
) -> File!Errno {
  async_suspend_with_error!!(fn(resolve, reject) {
    let path : Bytes = [..@encoding.encode(UTF8, path), b'\x00']
    let fs = fs_alloc()
    let result = fs_open(self, fs, path, flags, mode, fn(req) {
      let result = fs_get_result(req)
      if result < 0 {
        reject(Errno(result.to_int()))
      } else {
        resolve({ self, file: result })
      }
    })
    if result < 0 {
      reject(Errno(result))
    }
  })
}

///|
extern "c" fn fs_close(
  loop_ : Loop,
  req : Fs,
  file : File_,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_close"

///|
pub async fn File::close(self : File) -> Unit!Errno {
  async_suspend_with_error!!(fn(resolve, reject) {
    let fs = fs_alloc()
    let result = fs_close(self.self, fs, self.file, fn(req) {
      let result = fs_get_result(req)
      if result < 0 {
        reject(Errno(result.to_int()))
      } else {
        resolve(())
      }
    })
    if result < 0 {
      reject(Errno(result))
    }
  })
}

///|
extern "c" fn fs_get_result(req : Fs) -> Int64 = "moonbit_uv_fs_get_result"

///|
/// * Windows: HANLDE (void *)
/// * Unix (Linux/macOS): ssize_t
priv type File_ Int64

///|
extern "c" fn fs_read(
  loop_ : Loop,
  req : Fs,
  file : File_,
  bufs : FixedArray[Buf],
  offset : Int64,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_read"

///|
priv struct BytesView {
  bytes : Bytes
  start : Int
  len : Int
}

///|
fn BytesView::of(view : @bytes.View) -> BytesView = "%identity"

///|
fn BytesView::to(self : BytesView) -> @bytes.View = "%identity"

///|
pub async fn File::read(self : File) -> @bytes.View!Errno {
  async_suspend_with_error!!(fn(resolve, reject) {
    let fs = fs_alloc()
    let bytes = Bytes::make(1024, b'\x00')
    let buf = buf_alloc()
    buf_init(buf, bytes, 0, bytes.length())
    let bufs : FixedArray[Buf] = [buf]
    let result = fs_read(self.self, fs, self.file, bufs, 0, fn(req) {
      let result = fs_get_result(req)
      if result < 0 {
        reject(Errno(result.to_int()))
      } else {
        resolve(bytes[:result.to_int()])
      }
    })
    bufs.each(buf_free)
    if result < 0 {
      reject(Errno(result))
    }
  })
}

///|
extern "c" fn fs_write(
  loop_ : Loop,
  req : Fs,
  file : File_,
  bufs : FixedArray[Buf],
  offset : Int64,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_write"

///|
pub async fn File::write(self : File, bytes : @bytes.View) -> @bytes.View!Errno {
  async_suspend_with_error!!(fn(resolve, reject) {
    let fs = fs_alloc()
    let buf = {
      let buf = buf_alloc()
      let bytes = BytesView::of(bytes)
      buf_init(buf, bytes.bytes, bytes.start, bytes.len)
      buf
    }
    let bufs : FixedArray[Buf] = [buf]
    let result = fs_write(self.self, fs, self.file, bufs, 0, fn(req) {
      let result = fs_get_result(req)
      if result < 0 {
        reject(Errno(result.to_int()))
      } else {
        resolve(bytes[result.to_int():])
      }
    })
    bufs.each(buf_free)
    if result < 0 {
      reject(Errno(result))
    }
  })
}

///|
pub const STDIN : Int = 0

///|
pub fn Loop::stdin(self : Loop) -> File {
  { self, file: STDIN.to_int64() }
}

///|
pub const STDOUT = 1

///|
pub fn Loop::stdout(self : Loop) -> File {
  { self, file: STDOUT.to_int64() }
}

///|
pub const STDERR = 2

///|
pub fn Loop::stderr(self : Loop) -> File {
  { self, file: STDERR.to_int64() }
}
