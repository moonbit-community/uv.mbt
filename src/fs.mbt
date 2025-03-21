///|
extern type Fs

///|
pub fn fs_to_req(self : Fs) -> Req = "%identity"

///|
pub extern "c" fn fs_alloc() -> Fs = "moonbit_uv_fs_alloc"

///|
pub(all) enum OpenFlag {
  ReadOnly = 0x0
  WriteOnly = 0x1
  ReadWrite = 0x2
}

///|
pub extern "c" fn fs_open(
  loop_ : Loop,
  req : Fs,
  path : Bytes,
  flags : OpenFlag,
  mode : Int,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_open"

///|
pub extern "c" fn fs_close(
  loop_ : Loop,
  req : Fs,
  file : File,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_close"

///|
pub extern "c" fn fs_get_result(req : Fs) -> Int64 = "moonbit_uv_fs_get_result"

///|
pub(all) type File Int

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
pub extern "c" fn fs_req_cleanup(req : Fs) = "moonbit_uv_fs_req_cleanup"

///|
pub const STDIN : Int = 0

///|
pub const STDOUT = 1

///|
pub const STDERR = 2
