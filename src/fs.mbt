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
pub fn[Ntbs : ToNtbs] fs_open(
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
pub fn[Ntbs : ToNtbs] fs_unlink(
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
pub fn[Ntbs : ToNtbs] fs_mkdir(
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
pub fn[Ntbs : ToNtbs] fs_rmdir(
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
pub fn[Ntbs : ToNtbs] fs_scandir(
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
pub fn[Ntbs : ToNtbs] fs_rename(
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
pub fn[Ntbs : ToNtbs] fs_copyfile(
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
type Stat Bytes

///|
extern "c" fn moonbit_uv_stat_get_dev(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_dev"

///|
extern "c" fn moonbit_uv_stat_get_mode(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_mode"

///|
extern "c" fn moonbit_uv_stat_get_nlink(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_nlink"

///|
extern "c" fn moonbit_uv_stat_get_uid(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_uid"

///|
extern "c" fn moonbit_uv_stat_get_gid(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_gid"

///|
extern "c" fn moonbit_uv_stat_get_rdev(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_rdev"

///|
extern "c" fn moonbit_uv_stat_get_ino(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_ino"

///|
extern "c" fn moonbit_uv_stat_get_size(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_size"

///|
extern "c" fn moonbit_uv_stat_get_blksize(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_blksize"

///|
extern "c" fn moonbit_uv_stat_get_blocks(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_blocks"

///|
extern "c" fn moonbit_uv_stat_get_flags(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_flags"

///|
extern "c" fn moonbit_uv_stat_get_gen(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_gen"

///|
extern "c" fn moonbit_uv_stat_get_atim_sec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_atim_sec"

///|
extern "c" fn moonbit_uv_stat_get_atim_nsec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_atim_nsec"

///|
extern "c" fn moonbit_uv_stat_get_mtim_sec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_mtim_sec"

///|
extern "c" fn moonbit_uv_stat_get_mtim_nsec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_mtim_nsec"

///|
extern "c" fn moonbit_uv_stat_get_ctim_sec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_ctim_sec"

///|
extern "c" fn moonbit_uv_stat_get_ctim_nsec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_ctim_nsec"

///|
extern "c" fn moonbit_uv_stat_get_birthtim_sec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_birthtim_sec"

///|
extern "c" fn moonbit_uv_stat_get_birthtim_nsec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_birthtim_nsec"

///|
pub fn Stat::dev(self : Stat) -> UInt64 {
  moonbit_uv_stat_get_dev(self)
}

///|
pub fn Stat::mode(self : Stat) -> UInt64 {
  moonbit_uv_stat_get_mode(self)
}

///|
pub fn Stat::nlink(self : Stat) -> UInt64 {
  moonbit_uv_stat_get_nlink(self)
}

///|
pub fn Stat::uid(self : Stat) -> UInt64 {
  moonbit_uv_stat_get_uid(self)
}

///|
pub fn Stat::gid(self : Stat) -> UInt64 {
  moonbit_uv_stat_get_gid(self)
}

///|
pub fn Stat::rdev(self : Stat) -> UInt64 {
  moonbit_uv_stat_get_rdev(self)
}

///|
pub fn Stat::ino(self : Stat) -> UInt64 {
  moonbit_uv_stat_get_ino(self)
}

///|
pub fn Stat::size(self : Stat) -> UInt64 {
  moonbit_uv_stat_get_size(self)
}

///|
pub fn Stat::blksize(self : Stat) -> UInt64 {
  moonbit_uv_stat_get_blksize(self)
}

///|
pub fn Stat::blocks(self : Stat) -> UInt64 {
  moonbit_uv_stat_get_blocks(self)
}

///|
pub fn Stat::flags(self : Stat) -> UInt64 {
  moonbit_uv_stat_get_flags(self)
}

///|
pub fn Stat::gen(self : Stat) -> UInt64 {
  moonbit_uv_stat_get_gen(self)
}

///|
pub fn Stat::atim_sec(self : Stat) -> Int64 {
  moonbit_uv_stat_get_atim_sec(self)
}

///|
pub fn Stat::atim_nsec(self : Stat) -> Int64 {
  moonbit_uv_stat_get_atim_nsec(self)
}

///|
pub fn Stat::mtim_sec(self : Stat) -> Int64 {
  moonbit_uv_stat_get_mtim_sec(self)
}

///|
pub fn Stat::mtim_nsec(self : Stat) -> Int64 {
  moonbit_uv_stat_get_mtim_nsec(self)
}

///|
pub fn Stat::ctim_sec(self : Stat) -> Int64 {
  moonbit_uv_stat_get_ctim_sec(self)
}

///|
pub fn Stat::ctim_nsec(self : Stat) -> Int64 {
  moonbit_uv_stat_get_ctim_nsec(self)
}

///|
pub fn Stat::birthtim_sec(self : Stat) -> Int64 {
  moonbit_uv_stat_get_birthtim_sec(self)
}

///|
pub fn Stat::birthtim_nsec(self : Stat) -> Int64 {
  moonbit_uv_stat_get_birthtim_nsec(self)
}

///|
pub fn Stat::is_file(self : Stat) -> Bool {
  (self.mode() & _S_IFMT) == _S_IFREG
}

///|
pub fn Stat::is_directory(self : Stat) -> Bool {
  (self.mode() & _S_IFMT) == _S_IFDIR
}

///|
pub fn Stat::is_symlink(self : Stat) -> Bool {
  (self.mode() & _S_IFMT) == _S_IFLNK
}

///|
pub fn Stat::is_socket(self : Stat) -> Bool!Errno {
  if _S_IFSOCK == @uint64.max_value {
    raise Errno(ENOSYS)
  }
  (self.mode() & _S_IFMT) == _S_IFSOCK
}

///|
pub fn Stat::is_pipe(self : Stat) -> Bool {
  (self.mode() & _S_IFMT) == _S_IFIFO
}

///|
pub fn Stat::is_block_device(self : Stat) -> Bool!Errno {
  if _S_IFBLK == @uint64.max_value {
    raise Errno(ENOSYS)
  }
  (self.mode() & _S_IFMT) == _S_IFBLK
}

///|
pub fn Stat::is_character_device(self : Stat) -> Bool {
  (self.mode() & _S_IFMT) == _S_IFCHR
}

///|
extern "c" fn uv_fs_S_IFMT() -> UInt64 = "moonbit_uv_fs_S_IFMT"

///|
let _S_IFMT : UInt64 = uv_fs_S_IFMT()

///|
extern "c" fn uv_fs_S_IFREG() -> UInt64 = "moonbit_uv_fs_S_IFREG"

///|
let _S_IFREG : UInt64 = uv_fs_S_IFREG()

///|
extern "c" fn uv_fs_S_IFDIR() -> UInt64 = "moonbit_uv_fs_S_IFDIR"

///|
let _S_IFDIR : UInt64 = uv_fs_S_IFDIR()

///|
extern "c" fn uv_fs_S_IFLNK() -> UInt64 = "moonbit_uv_fs_S_IFLNK"

///|
let _S_IFLNK : UInt64 = uv_fs_S_IFLNK()

///|
extern "c" fn uv_fs_S_IFSOCK() -> UInt64 = "moonbit_uv_fs_S_IFSOCK"

///|
let _S_IFSOCK : UInt64 = uv_fs_S_IFSOCK()

///|
extern "c" fn uv_fs_S_IFIFO() -> UInt64 = "moonbit_uv_fs_S_IFIFO"

///|
let _S_IFIFO : UInt64 = uv_fs_S_IFIFO()

///|
extern "c" fn uv_fs_S_IFBLK() -> UInt64 = "moonbit_uv_fs_S_IFBLK"

///|
let _S_IFBLK : UInt64 = uv_fs_S_IFBLK()

///|
extern "c" fn uv_fs_S_IFCHR() -> UInt64 = "moonbit_uv_fs_S_IFCHR"

///|
let _S_IFCHR : UInt64 = uv_fs_S_IFCHR()

///|
extern "c" fn uv_fs_get_statbuf(req : Fs) -> Stat = "moonbit_uv_fs_get_statbuf"

///|
extern "c" fn uv_fs_stat(
  self : Loop,
  req : Fs,
  path : Bytes,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_stat"

///|
pub fn[Ntbs : ToNtbs] fs_stat(
  self : Loop,
  path : Ntbs,
  k : (Fs, Stat) -> Unit,
  e : (Fs, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      e(req, Errno::of_int(status))
    } else {
      let statbuf = uv_fs_get_statbuf(req)
      k(req, statbuf)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_stat(self, req, path.to_ntbs(), cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_lstat(
  self : Loop,
  req : Fs,
  path : Bytes,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_lstat"

///|
pub fn[Ntbs : ToNtbs] fs_lstat(
  self : Loop,
  path : Ntbs,
  k : (Fs, Stat) -> Unit,
  e : (Fs, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      e(req, Errno::of_int(status))
    } else {
      let statbuf = uv_fs_get_statbuf(req)
      k(req, statbuf)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_lstat(self, req, path.to_ntbs(), cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_fstat(
  self : Loop,
  req : Fs,
  file : File,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_fstat"

///|
pub fn fs_fstat(
  self : Loop,
  file : File,
  k : (Fs, Stat) -> Unit,
  e : (Fs, Errno) -> Unit
) -> Unit!Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      e(req, Errno::of_int(status))
    } else {
      let statbuf = uv_fs_get_statbuf(req)
      k(req, statbuf)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_fstat(self, req, file, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn[Ntbs : ToNtbs] fs_realpath(
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

///|
extern "c" fn uv_F_OK() -> Int = "moonbit_uv_F_OK"

///|
let _F_OK : Int = uv_F_OK()

///|
extern "c" fn uv_R_OK() -> Int = "moonbit_uv_R_OK"

///|
let _R_OK : Int = uv_R_OK()

///|
extern "c" fn uv_W_OK() -> Int = "moonbit_uv_W_OK"

///|
let _W_OK : Int = uv_W_OK()

///|
extern "c" fn uv_X_OK() -> Int = "moonbit_uv_X_OK"

///|
let _X_OK : Int = uv_X_OK()

///|
type AccessFlags Int

///|
pub fn AccessFlags::new(
  read~ : Bool = false,
  write~ : Bool = false,
  execute~ : Bool = false
) -> AccessFlags {
  if not(read) && not(write) && not(execute) {
    return _F_OK
  }
  let mut flags = 0
  if read {
    flags = flags | _R_OK
  }
  if write {
    flags = flags | _W_OK
  }
  if execute {
    flags = flags | _X_OK
  }
  return flags
}

///|
extern "c" fn uv_fs_access(
  self : Loop,
  req : Fs,
  path : Bytes,
  mode : Int,
  cb : (Fs) -> Unit
) -> Int = "moonbit_uv_fs_access"

///|
pub fn[Ntbs : ToNtbs] fs_access(
  self : Loop,
  path : Ntbs,
  mode : AccessFlags,
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
  let status = uv_fs_access(self, req, path.to_ntbs(), mode._, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
