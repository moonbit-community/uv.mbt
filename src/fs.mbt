///|
type Fs

///|
pub impl ToReq for Fs with to_req(self : Fs) -> Req = "%identity"

///|
extern "c" fn uv_fs_make() -> Fs = "moonbit_uv_fs_make"

///|
type OpenFlags Int

///|
pub fn OpenFlags::read(create~ : Bool = false) -> OpenFlags {
  let mut flags = _O_RDONLY
  if create {
    flags = flags | _O_CREAT
  }
  flags
}

///|
pub fn OpenFlags::write(create~ : Bool = false) -> OpenFlags {
  let mut flags = _O_WRONLY
  if create {
    flags = flags | _O_CREAT
  }
  flags
}

///|
pub fn OpenFlags::read_write(create~ : Bool = false) -> OpenFlags {
  let mut flags = _O_RDWR
  if create {
    flags = flags | _O_CREAT
  }
  flags
}

///|
extern "c" fn uv_fs_O_RDONLY() -> Int = "moonbit_uv_fs_O_RDONLY"

///|
let _O_RDONLY : Int = uv_fs_O_RDONLY()

///|
extern "c" fn uv_fs_O_WRONLY() -> Int = "moonbit_uv_fs_O_WRONLY"

///|
let _O_WRONLY : Int = uv_fs_O_WRONLY()

///|
extern "c" fn uv_fs_O_RDWR() -> Int = "moonbit_uv_fs_O_RDWR"

///|
let _O_RDWR : Int = uv_fs_O_RDWR()

///|
extern "c" fn uv_fs_O_CREAT() -> Int = "moonbit_uv_fs_O_CREAT"

///|
let _O_CREAT : Int = uv_fs_O_CREAT()

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
pub(open) trait ToNtbs {
  to_ntbs(Self) -> Bytes
}

///|
pub impl ToNtbs for String with to_ntbs(self : String) -> Bytes {
  let buffer = @buffer.new()
  @encoding.encode_to(self, buffer, encoding=UTF8)
  buffer.write_byte(0)
  return buffer.contents()
}

///|
pub impl ToNtbs for Bytes with to_ntbs(self : Bytes) -> Bytes {
  let buffer = @buffer.new()
  buffer.write_bytes(self)
  buffer.write_byte(0)
  return buffer.contents()
}

///|
pub impl ToNtbs for @string.View with to_ntbs(self : @string.View) -> Bytes {
  self.to_string().to_ntbs()
}

///|
pub impl ToNtbs for @bytes.View with to_ntbs(self : @bytes.View) -> Bytes {
  let buffer = @buffer.new()
  buffer.write_bytesview(self)
  buffer.write_byte(0)
  return buffer.contents()
}

///|
pub fn fs_open[Ntbs : ToNtbs](
  self : Loop,
  path : Ntbs,
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
  let path = path.to_ntbs()
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
extern "c" fn uv_fs_get_result(req : Fs) -> Int64 = "moonbit_uv_fs_get_result"

///|
fn Fs::result(self : Fs) -> Int64 {
  uv_fs_get_result(self)
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
  offset~ : Int64 = -1,
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
  offset~ : Int64 = -1,
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
pub fn stdin() -> File {
  0
}

///|
pub fn stdout() -> File {
  1
}

///|
pub fn stderr() -> File {
  2
}

///|
extern "c" fn uv_fs_unlink(
  self : Loop,
  req : Fs,
  path : Bytes,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_unlink"

///|
pub fn fs_unlink[Ntbs : ToNtbs](
  self : Loop,
  path : Ntbs,
  k : (Fs) -> Unit,
  e : (Fs, Error) -> Unit
) -> Unit!Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      e(req, Errno::of_int(status))
    } else {
      k(req)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_unlink(self, req, path.to_ntbs(), cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_mkdir(
  self : Loop,
  req : Fs,
  path : Bytes,
  mode : Int,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_mkdir"

///|
pub fn fs_mkdir[Ntbs : ToNtbs](
  self : Loop,
  path : Ntbs,
  mode : Int,
  k : (Fs) -> Unit,
  e : (Fs, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      e(req, Errno::of_int(status))
    } else {
      k(req)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_mkdir(self, req, path.to_ntbs(), mode, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_rmdir(
  self : Loop,
  req : Fs,
  path : Bytes,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_rmdir"

///|
pub fn fs_rmdir[Ntbs : ToNtbs](
  self : Loop,
  path : Ntbs,
  k : (Fs) -> Unit,
  e : (Fs, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      e(req, Errno::of_int(status))
    } else {
      k(req)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_rmdir(self, req, path.to_ntbs(), cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_scandir(
  self : Loop,
  req : Fs,
  path : Bytes,
  flags : Int,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_scandir"

///|
type Dirent

///|
pub enum DirentType {
  Unknown
  File
  Dir
  Link
  Fifo
  Socket
  Char
  Block
} derive(Show)

///|
pub impl ToJson for DirentType with to_json(self) -> Json {
  Json::string(self.to_string())
}

///|
fn init {
  ignore(DirentType::Unknown)
  ignore(DirentType::File)
  ignore(DirentType::Dir)
  ignore(DirentType::Link)
  ignore(DirentType::Fifo)
  ignore(DirentType::Socket)
  ignore(DirentType::Char)
  ignore(DirentType::Block)
}

///|
extern "c" fn uv_dirent_make() -> Dirent = "moonbit_uv_dirent_make"

///|
extern "c" fn uv_dirent_get_name(self : Dirent) -> @c.Pointer[Byte] = "moonbit_uv_dirent_get_name"

///|
pub fn Dirent::name(self : Dirent) -> String {
  let name = uv_dirent_get_name(self)
  let buffer = @buffer.new()
  for i = 0; name[i] != 0; i = i + 1 {
    buffer.write_byte(name[i])
  }
  let bytes = buffer.contents()
  return @encoding.decode_lossy(encoding=UTF8, bytes)
}

///|
extern "c" fn uv_dirent_get_type(self : Dirent) -> DirentType = "moonbit_uv_dirent_get_type"

///|
pub fn Dirent::type_(self : Dirent) -> DirentType {
  uv_dirent_get_type(self)
}

///|
extern "c" fn uv_fs_scandir_next(req : Fs, ent : Dirent) -> Int = "moonbit_uv_fs_scandir_next"

///|
pub fn fs_scandir[Ntbs : ToNtbs](
  self : Loop,
  path : Ntbs,
  flags : Int,
  k : (Fs) -> Unit,
  e : (Fs, Errno) -> Unit
) -> Unit!Errno {
  let req = uv_fs_make()
  let status = uv_fs_scandir(self, req, path.to_ntbs(), flags, fn(req) {
    let status = uv_fs_get_result(req).to_int()
    if status < 0 {
      return e(req, Errno::of_int(status))
    } else {
      k(req)
    }
  })
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn fs_scandir_next(req : Fs) -> Dirent!Errno {
  let dirent = uv_dirent_make()
  let status = uv_fs_scandir_next(req, dirent)
  if status < 0 {
    raise Errno::of_int(status)
  }
  dirent
}

///|
extern "c" fn uv_fs_rename(
  self : Loop,
  req : Fs,
  path : Bytes,
  new_path : Bytes,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_rename"

///|
pub fn fs_rename[Ntbs : ToNtbs](
  self : Loop,
  path : Ntbs,
  new_path : Ntbs,
  k : (Fs) -> Unit,
  e : (Fs, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      e(req, Errno::of_int(status))
    } else {
      k(req)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_rename(self, req, path.to_ntbs(), new_path.to_ntbs(), cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
type CopyFileFlags Int

///|
extern "c" fn uv_fs_COPYFILE_EXCL() -> Int = "moonbit_uv_fs_COPYFILE_EXCL"

///|
extern "c" fn uv_fs_COPYFILE_FICLONE() -> Int = "moonbit_uv_fs_COPYFILE_FICLONE"

///|
extern "c" fn uv_fs_COPYFILE_FICLONE_FORCE() -> Int = "moonbit_uv_fs_COPYFILE_FICLONE_FORCE"

///|
pub(all) enum CopyOnWrite {
  False
  True
  Force
}

///|
pub fn CopyFileFlags::new(
  allow_exists~ : Bool = true,
  copy_on_write~ : CopyOnWrite = False
) -> CopyFileFlags {
  let mut flags = if allow_exists { 0 } else { uv_fs_COPYFILE_EXCL() }
  match copy_on_write {
    False => ()
    True => flags = flags | uv_fs_COPYFILE_FICLONE()
    Force => flags = flags | uv_fs_COPYFILE_FICLONE_FORCE()
  }
  return flags
}

///|
extern "c" fn uv_fs_copyfile(
  self : Loop,
  req : Fs,
  path : Bytes,
  new_path : Bytes,
  flags : Int,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_copyfile"

///|
pub fn fs_copyfile[Ntbs : ToNtbs](
  self : Loop,
  path : Ntbs,
  new_path : Ntbs,
  flags : CopyFileFlags,
  k : (Fs) -> Unit,
  e : (Fs, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      e(req, Errno::of_int(status))
    } else {
      k(req)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_copyfile(
    self,
    req,
    path.to_ntbs(),
    new_path.to_ntbs(),
    flags._,
    cb,
  )
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_cwd(buffer : Bytes, length : FixedArray[Int]) -> Int = "moonbit_uv_cwd"

///|
pub fn cwd() -> String!Errno {
  let buffer = Bytes::make(1024, 0)
  let length : FixedArray[Int] = [buffer.length()]
  let mut status = uv_cwd(buffer, length)
  if status == uv_ENOBUFS() {
    let buffer = Bytes::make(length[0], 0)
    status = uv_cwd(buffer, length)
  }
  if status < 0 {
    raise Errno::of_int(status)
  }
  return @encoding.decode_lossy(encoding=UTF8, buffer[:length[0]])
}

///|
extern "c" fn uv_fs_get_ptr(req : Fs) -> @c.Pointer[Unit] = "moonbit_uv_fs_get_ptr"

///|
extern "c" fn uv_fs_realpath(
  uv : Loop,
  req : Fs,
  path : Bytes,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_realpath"

///|
pub fn fs_realpath[Ntbs : ToNtbs](
  self : Loop,
  path : Ntbs,
  k : (Fs, String) -> Unit,
  e : (Fs, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      e(req, Errno::of_int(status))
    } else {
      let ptr : @c.Pointer[Byte] = uv_fs_get_ptr(req).cast()
      let buffer = @buffer.new()
      for i = 0; ptr[i] != 0; i = i + 1 {
        buffer.write_byte(ptr[i])
      }
      let bytes = buffer.contents()
      k(req, @encoding.decode_lossy(encoding=UTF8, bytes))
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_realpath(self, req, path.to_ntbs(), cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
