///|
type Fs

///|
pub fn Fs::to_req(self : Fs) -> Req = "%identity"

///|
extern "c" fn uv_fs_make() -> Fs = "moonbit_uv_fs_make"

///|
type OpenFlags Int

///|
pub fn OpenFlags::read() -> OpenFlags {
  return uv_fs_O_RDONLY()
}

///|
pub fn OpenFlags::write() -> OpenFlags {
  return uv_fs_O_WRONLY()
}

///|
pub fn OpenFlags::read_write() -> OpenFlags {
  return uv_fs_O_RDWR()
}

///|
extern "c" fn uv_fs_O_RDONLY() -> Int = "moonbit_uv_fs_O_RDONLY"

///|
extern "c" fn uv_fs_O_WRONLY() -> Int = "moonbit_uv_fs_O_WRONLY"

///|
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
  open_cb : (Fs, File) -> Unit,
  error_cb : (Fs, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Fs) {
    let result = req.result().to_int()
    if result < 0 {
      error_cb(req, Errno::of_int(result))
    } else {
      open_cb(req, File(result))
    }
  }

  let req = uv_fs_make()
  let path = to_c_string(path)
  let status = uv_fs_open(self, req, path, flags._, mode, cb)
  if status < 0 {
    raise Errno::of_int(status)
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
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_result(req : Fs) -> Int64 = "moonbit_uv_fs_result"

///|
fn Fs::result(self : Fs) -> Int64 {
  uv_fs_result(self)
}

///|
type File Int

///|
extern "c" fn uv_fs_read(
  self : Loop,
  req : Fs,
  file : File,
  bufs_base : FixedArray[Bytes],
  bufs_offset : FixedArray[Int],
  bufs_length : FixedArray[Int],
  offset : Int64,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_read"

///|
pub fn fs_read(
  self : Loop,
  file : File,
  bufs : Array[@bytes.View],
  offset : Int64,
  read_cb : (Fs, Int) -> Unit,
  error_cb : (Fs, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Fs) {
    let result = req.result()
    if result < 0 {
      error_cb(req, Errno::of_int(result.to_int()))
    } else {
      read_cb(req, result.to_int())
    }
  }

  let req = uv_fs_make()
  let bufs_size = bufs.length()
  let bufs_base : FixedArray[Bytes] = FixedArray::make(bufs_size, [])
  let bufs_offset = FixedArray::make(bufs_size, 0)
  let bufs_length = FixedArray::make(bufs_size, 0)
  for i in 0..<bufs.length() {
    bufs_base[i] = bufs[i].data()
    bufs_offset[i] = bufs[i].start_offset()
    bufs_length[i] = bufs[i].length()
  }
  let status = uv_fs_read(
    self, req, file, bufs_base, bufs_offset, bufs_length, offset, cb,
  )
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_write(
  self : Loop,
  req : Fs,
  file : File,
  bufs_base : FixedArray[Bytes],
  bufs_offset : FixedArray[Int],
  bufs_length : FixedArray[Int],
  offset : Int64,
  write_cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_write"

///|
pub fn fs_write(
  self : Loop,
  file : File,
  bufs : Array[@bytes.View],
  offset : Int64,
  write_cb : (Fs, Int) -> Unit,
  error_cb : (Fs, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Fs) {
    let result = req.result().to_int()
    if result < 0 {
      error_cb(req, Errno::of_int(result))
    } else {
      write_cb(req, result)
    }
  }

  let req = uv_fs_make()
  let bufs_size = bufs.length()
  let bufs_base : FixedArray[Bytes] = FixedArray::make(bufs_size, [])
  let bufs_offset = FixedArray::make(bufs_size, 0)
  let bufs_length = FixedArray::make(bufs_size, 0)
  for i in 0..<bufs_size {
    bufs_base[i] = bufs[i].data()
    bufs_offset[i] = bufs[i].start_offset()
    bufs_length[i] = bufs[i].length()
  }
  let status = uv_fs_write(
    self, req, file, bufs_base, bufs_offset, bufs_length, offset, cb,
  )
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub let stdin : File = 0

///|
pub let stdout : File = 1

///|
pub let stderr : File = 2
