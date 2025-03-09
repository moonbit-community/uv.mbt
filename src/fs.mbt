///|
extern type Fs

///|
impl ToReq for Fs with to_req(self : Fs) -> Req = "%identity"

///|
pub extern "c" fn fs_alloc() -> Fs = "moonbit_uv_fs_alloc"

///|
pub extern "c" fn fs_open(
  loop_ : Loop,
  req : Fs,
  path : Bytes,
  flags : Int,
  mode : Int,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_open"

///|
pub async fn Loop::open(
  self : Loop,
  path : String,
  flags : Int,
  mode : Int
) -> Fs!Errno {
  async_suspend_with_error!!(fn(resolve, reject) {
    let path : Bytes = [..@encoding.encode(UTF8, path), b'\x00']
    let fs = fs_alloc()
    let result = fs_open(self, fs, path, flags, mode, fn(fs) {
      let result = fs_get_result(fs)
      if result < 0 {
        reject(Errno(result.to_int()))
      } else {
        resolve(fs)
      }
    })
    if result < 0 {
      reject(Errno(result))
    }
  })
}

///|
pub extern "c" fn fs_close(
  loop_ : Loop,
  req : Fs,
  file : Int64,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_close"

///|
pub extern "c" fn fs_get_result(req : Fs) -> Int64 = "moonbit_uv_fs_get_result"

///|
/// * Windows: HANLDE (void *)
/// * Unix (Linux/macOS): ssize_t
pub typealias File = Int64

///|
pub extern "c" fn fs_read(
  loop_ : Loop,
  req : Fs,
  file : File,
  bufs : FixedArray[Buf],
  offset : Int64,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_read"

///|
pub extern "c" fn fs_write(
  loop_ : Loop,
  req : Fs,
  file : File,
  bufs : FixedArray[Buf],
  offset : Int64,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_write"

///|
pub const FS_O_RDONLY : Int = 0x0000

///|
pub const FS_O_WRONLY : Int = 0x0001

///|
pub const FS_O_RDWR : Int = 0x0002

///|
pub const STDIN = 0

///|
pub const STDOUT = 1

///|
pub const STDERR = 2
