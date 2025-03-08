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

pub const FS_O_WRONLY : Int = 0x0001

pub const FS_O_RDWR : Int = 0x0002

///|
pub const STDIN = 0

///|
pub const STDOUT = 1

///|
pub const STDERR = 2
