///|
type File @uv.File

///|
pub fn File::close(self : File, loc~ : SourceLoc = _) -> Unit raise {
  let uv = uv()
  backtrace(loc~, fn() { uv.fs_close_sync(self._) })
}

///|
pub impl Readable for File with read(self : File) -> Iter[@bytes.View] raise Error {
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
pub impl Writable for File with write(self : File, content : Iter[@bytes.View]) -> Unit raise Error {
  let uv = uv()
  content.each(fn(bytes) { uv.fs_write_sync(self._, [bytes]) })
}

///|
pub fn Path::open(self : Path, loc~ : SourceLoc = _) -> File raise {
  let uv = uv()
  backtrace(loc~, fn() {
    uv.fs_open_sync(self.to_string(), @uv.OpenFlags::read_only(), 0o644) catch {
      error => raise error
    }
  })
}

///|
pub fn Path::read(
  self : Path,
  loc~ : SourceLoc = _
) -> Iter[@bytes.View] raise Error {
  let file = self.open()
  fn(yield_) {
    backtrace(loc~, fn() { file.read().each(yield_) })
    file.close()
  }
}

///|
pub impl Readable for Path with read(self : Path) -> Iter[@bytes.View] raise Error {
  self.read()
}

///|
pub fn Path::write(
  self : Path,
  content : Iter[@bytes.View],
  loc~ : SourceLoc = _
) -> Unit raise Error {
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
pub impl Writable for Path with write(self : Path, content : Iter[@bytes.View]) -> Unit raise Error {
  self.write(content)
}

///|
pub fn Path::unlink(self : Path, loc~ : SourceLoc = _) -> Unit raise Error {
  let uv = uv()
  backtrace(loc~, fn() { uv.fs_unlink_sync(self.to_string()) })
}

///|
pub fn Path::rmdir(self : Path, loc~ : SourceLoc = _) -> Unit raise Error {
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
) -> Unit raise Error {
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
pub fn Path::stat(self : Path, loc~ : SourceLoc = _) -> Stat raise Error {
  let uv = uv()
  backtrace(loc~, fn() {
    uv.fs_stat_sync(self.to_string()) catch {
      @uv.Errno(ENOENT) => raise SystemError::not_found(self)
      error => raise error
    }
  })
}

///|
pub fn Path::exists(self : Path, loc~ : SourceLoc = _) -> Bool raise Error {
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

///|
pub fn Path::iter(self : Path) -> Iter[Path] raise {
  let uv = uv()
  let req = uv.fs_scandir_sync(self.to_string(), 0)
  fn(yield_) {
    try {
      while true {
        let dirent = @uv.fs_scandir_next(req)
        let name = dirent.name()
        yield_(self / ToPath::to_path(name))
      }
    } catch {
      @uv.Errno(EOF) => ()
      e => raise e
    }
  }
}

///|
pub fn Path::is_dir(self : Path, loc~ : SourceLoc = _) -> Bool raise Error {
  backtrace(loc~, fn() {
    let stat = self.stat()
    stat.is_dir()
  })
}

///|
pub fn Path::is_file(self : Path, loc~ : SourceLoc = _) -> Bool raise Error {
  backtrace(loc~, fn() {
    let stat = self.stat()
    stat.is_file()
  })
}

///|
pub fn Path::mkdir(
  self : Path,
  mode~ : Int = 0o777,
  loc~ : SourceLoc = _
) -> Unit raise {
  let uv = uv()
  backtrace(loc~, fn() { uv.fs_mkdir_sync(self.to_string(), mode) })
}

///|
pub fn[Target : ToPath] Path::copy_to(
  self : Path,
  target : Target,
  recursive~ : Bool = false,
  overwrite~ : Bool = false,
  loc~ : SourceLoc = _
) -> Unit raise Error {
  let uv = uv()
  backtrace(loc~, fn() {
    let target : Path = target.to_path()
    if self.is_dir() {
      if not(recursive) {
        raise SystemError::is_directory(self)
      }
      if not(overwrite) && target.exists() {
        raise SystemError::exists(target)
      }
      target.mkdir()
      self
      .iter()
      .each(fn(entry) {
        let target_entry = target / entry.relative_to(self)
        entry.copy_to(target_entry, recursive~, overwrite~)
      })
    } else {
      uv.fs_copyfile_sync(
        self.to_string(),
        target.to_string(),
        @uv.CopyFileFlags::new(allow_exists=overwrite),
      )
    }
  })
}
