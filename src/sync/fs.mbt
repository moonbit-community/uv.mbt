///|
type File @uv.File

///|
pub fn File::close(self : File, loc~ : SourceLoc = _) -> Unit! {
  let uv = uv()
  backtrace(loc~, fn() { uv.fs_close_sync(self._) })
}

///|
pub impl Readable for File with read(self : File) -> Iter[@bytes.View]!Error {
  fn(yield_) {
    let uv = uv()
    let bytes = Bytes::make(256, 0)
    while true {
      let count = uv.fs_read_sync(self._, [bytes[:]])
      if count == 0 {
        break
      }
      yield_(bytes[:count])
    }
  }
}

///|
pub impl Writable for File with write(self : File, content : Iter[@bytes.View]) -> Unit!Error {
  let uv = uv()
  content.each(fn(bytes) { uv.fs_write_sync(self._, [bytes]) })
}

///|
pub fn Path::open(self : Path, loc~ : SourceLoc = _) -> File! {
  let uv = uv()
  backtrace(loc~, fn() {
    try uv.fs_open_sync(self.to_string(), @uv.OpenFlags::read_only(), 0o644) catch {
      error => raise error
    }
  })
}

///|
pub fn Path::read(self : Path, loc~ : SourceLoc = _) -> Iter[@bytes.View]!Error {
  let file = self.open()
  fn(yield_) {
    backtrace(loc~, fn() { file.read().each(yield_) })
    file.close()
  }
}

///|
pub impl Readable for Path with read(self : Path) -> Iter[@bytes.View]!Error {
  self.read()
}

///|
pub fn Path::write(
  self : Path,
  content : Iter[@bytes.View],
  loc~ : SourceLoc = _
) -> Unit!Error {
  let uv = uv()
  backtrace(loc~, fn() {
    let file = uv.fs_open_sync(
      self.to_string(),
      @uv.OpenFlags::write_only(create=true, truncate=true),
      0o644,
    )
    let file = File(file)
    file.write(content)
    file.close()
  })
}

///|
pub impl Writable for Path with write(self : Path, content : Iter[@bytes.View]) -> Unit!Error {
  self.write(content)
}

///|
pub fn Path::unlink(self : Path, loc~ : SourceLoc = _) -> Unit!Error {
  let uv = uv()
  backtrace(loc~, fn() { uv.fs_unlink_sync(self.to_string()) })
}

///|
pub fn Path::rmdir(self : Path, loc~ : SourceLoc = _) -> Unit!Error {
  let uv = uv()
  backtrace(loc~, fn() { uv.fs_rmdir_sync(self.to_string()) })
}

///|
pub fn Path::access(
  self : Path,
  read~ : Bool = false,
  write~ : Bool = false,
  execute~ : Bool = false,
  loc~ : SourceLoc = _
) -> Unit!Error {
  let uv = uv()
  backtrace(loc~, fn() {
    uv.fs_access_sync(
      self.to_string(),
      @uv.AccessFlags::new(read~, write~, execute~),
    )
  })
}

///|
type Stat @uv.Stat

///|
pub fn Stat::is_file(self : Stat) -> Bool {
  self._.is_regular()
}

///|
pub fn Stat::is_dir(self : Stat) -> Bool {
  self._.is_directory()
}

///|
pub fn Path::stat(self : Path, loc~ : SourceLoc = _) -> Stat!Error {
  let uv = uv()
  backtrace(loc~, fn() {
    try uv.fs_stat_sync(self.to_string()) catch {
      @uv.Errno(ENOENT) => raise SystemError::not_found(self)
      error => raise error
    }
  })
}

///|
pub fn Path::exists(self : Path, loc~ : SourceLoc = _) -> Bool!Error {
  backtrace(loc~, fn() {
    try {
      self.stat() |> ignore()
      true
    } catch {
      SystemError(NotFound(_), _) => false
      error => raise error
    }
  })
}
