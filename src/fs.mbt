///|
type Fs

///|
pub fn Fs::to_req(self : Fs) -> Req = "%identity"

///|
extern "c" fn uv_fs_make() -> Fs = "moonbit_uv_fs_make"

type OpenFlags Int

pub fn OpenFlags::read() -> OpenFlags {
  return uv_fs_O_RDONLY()
}

pub fn OpenFlags::write() -> OpenFlags {
  return uv_fs_O_WRONLY()
}

pub fn OpenFlags::read_write() -> OpenFlags {
  return uv_fs_O_RDWR()
}

extern "c" fn uv_fs_O_RDONLY() -> Int = "moonbit_uv_fs_O_RDONLY"

extern "c" fn uv_fs_O_WRONLY() -> Int = "moonbit_uv_fs_O_WRONLY"

extern "c" fn uv_fs_O_RDWR() -> Int = "moonbit_uv_fs_O_RDWR"

///|
extern "c" fn uv_fs_open(
  self : Loop,
  req : Fs,
  path : Bytes,
  flags : Int,
  mode : Int,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_open"

///|
pub fn fs_open(
  self : Loop,
  path : String,
  flags : OpenFlags,
  mode : Int,
  cb : (Fs) -> Unit
) -> Unit!Errno {
  let req = uv_fs_make()
  let path = to_c_string(path)
  let status = uv_fs_open(self, req, path, flags._, mode, cb)
  if status < 0 {
    raise Errno(status)
  }
}

///|
extern "c" fn uv_fs_close(
  self : Loop,
  req : Fs,
  file : File,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_close"

///|
pub fn fs_close(self : Loop, file : File, cb : (Fs) -> Unit) -> Unit!Errno {
  let req = uv_fs_make()
  let status = uv_fs_close(self, req, file, cb)
  if status < 0 {
    raise Errno(status)
  }
}

///|
extern "c" fn uv_fs_result(req : Fs) -> Int64 = "moonbit_uv_fs_result"

///|
pub fn Fs::result(self : Fs) -> Int64 {
  uv_fs_result(self)
}

pub fn Fs::file(self : Fs) -> File!Errno {
  let result = uv_fs_result(self)
  if result < 0 {
    raise Errno(result.to_int())
  }
  File(result.to_int())
}

///|
type File Int

///|
extern "c" fn uv_fs_read(
  self : Loop,
  req : Fs,
  file : File,
  bufs : FixedArray[Buf],
  offset : Int64,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_read"

///|
pub fn fs_read(
  self : Loop,
  file : File,
  bufs : Array[@bytes.View],
  offset : Int64,
  cb : (Fs) -> Unit
) -> Unit!Errno {
  let req = uv_fs_make()
  let bufs = FixedArray::makei(bufs.length(), fn(i) {
    Buf::make()..init(
      bufs[i].data(),
      bufs[i].start_offset(),
      bufs[i].length().reinterpret_as_uint(),
    )
  })
  let status = uv_fs_read(self, req, file, bufs, offset, cb)
  if status < 0 {
    raise Errno(status)
  }
}

///|
extern "c" fn uv_fs_write(
  self : Loop,
  req : Fs,
  file : File,
  bufs : FixedArray[Buf],
  offset : Int64,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_write"

///|
pub fn fs_write(
  self : Loop,
  file : File,
  bufs : Array[@bytes.View],
  offset : Int64,
  cb : (Fs) -> Unit
) -> Unit!Errno {
  let req = uv_fs_make()
  let bufs = FixedArray::makei(bufs.length(), fn(i) {
    Buf::make()..init(
      bufs[i].data(),
      bufs[i].start_offset(),
      bufs[i].length().reinterpret_as_uint(),
    )
  })
  let status = uv_fs_write(self, req, file, bufs, offset, cb)
  if status < 0 {
    raise Errno(status)
  }
}

///|
pub let stdin : File = 0

///|
pub let stdout : File = 1

///|
pub let stderr : File = 2
