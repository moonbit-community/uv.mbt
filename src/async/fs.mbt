// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
type File @uv.File

///|
pub async fn File::close(self : File, loc~ : SourceLoc = _) -> Unit raise {
  let uv = uv()
  backtrace(loc~, fn() {
    async_suspend_with_error(fn(resolve, reject : (Error) -> Unit) {
      try
        uv.fs_close(self.inner(), fn() { resolve(()) }, fn(e) { reject(e) })
        |> ignore()
      catch {
        e => reject(e)
      }
    })
  })
}

///|
pub enum FileType {
  File
  Directory
  Symlink
  Socket
  Fifo
  BlockDevice
  CharacterDevice
  Unknown
}

///|
pub impl Readable for File with read(self : File) {
  fn read(
    uv : @uv.Loop,
    file : @uv.File,
    yield_ : async (@bytes.View) -> Unit raise,
    resolve : (Unit) -> Unit,
    reject : (Error) -> Unit
  ) -> Unit {
    try {
      let bytes = Bytes::make(256, 0)
      uv.fs_read(
        file,
        [bytes[:]],
        fn(count) {
          if count == 0 {
            resolve(())
          } else {
            async_run(fn() {
              try {
                yield_(bytes[:count])
                read(uv, file, yield_, resolve, reject)
              } catch {
                e => reject(e)
              }
            })
          }
        },
        fn(e) { reject(e) },
      )
      |> ignore()
    } catch {
      e => reject(e)
    }
  }

  fn(yield_) {
    let uv = uv()
    async_suspend_with_error(fn(resolve, reject) {
      read(uv, self.inner(), yield_, resolve, reject)
    })
  }
}

///|
pub impl Writable for File with write(self : File, bytes : Iter[@bytes.View]) {
  fn write(
    uv : @uv.Loop,
    file : @uv.File,
    bytes : @bytes.View,
    resolve : (Unit) -> Unit,
    reject : (Error) -> Unit
  ) {
    if bytes.length() == 0 {
      resolve(())
      return
    }
    try
      uv.fs_write(
        file,
        [bytes[:]],
        fn(count) { write(uv, file, bytes[count:], resolve, reject) },
        fn(e) { reject(e) },
      )
      |> ignore()
    catch {
      e => reject(e)
    }
  }

  let uv = uv()
  bytes.each(fn(bytes) {
    async_suspend_with_error(fn(resolve, reject) {
      write(uv, self.inner(), bytes, resolve, reject)
    })
  })
}

///|
pub async fn Path::open(self : Path, loc~ : SourceLoc = _) -> File raise {
  let uv = uv()
  backtrace(loc~, fn() {
    async_suspend_with_error(fn(resolve, reject) {
      try
        uv.fs_open(
          self.to_string(),
          @uv.OpenFlags::read_only(),
          0o644,
          fn(file) { resolve(File::File(file)) },
          fn(e) { reject(e) },
        )
        |> ignore()
      catch {
        e => reject(e)
      }
    }) catch {
      @uv.ENOENT => raise ErrorTrace::new(FileSystemError::NotFound(self))
      error => raise error
    }
  })
}

///|
pub fn Path::read(self : Path, loc~ : SourceLoc = _) -> Iter[@bytes.View] raise {
  let uv = uv()
  fn(yield_) {
    backtrace(loc~, fn() {
      async_suspend_with_error(fn(
        resolve : (Unit) -> Unit,
        reject : (Error) -> Unit
      ) {
        try
          uv.fs_open(
            self.to_string(),
            @uv.OpenFlags::read_only(),
            0o644,
            fn(file) {
              let file = File::File(file)
              async_run(fn() {
                try {
                  file.read().each(fn(bytes) { yield_(bytes) })
                  uv.fs_close(file.inner(), fn() { resolve(()) }, fn(e) {
                    reject(e)
                  })
                  |> ignore()
                } catch {
                  e => reject(e)
                }
              })
            },
            fn(e) { reject(e) },
          )
          |> ignore()
        catch {
          e => reject(e)
        }
      }) catch {
        @uv.ENOENT => raise ErrorTrace::new(FileSystemError::NotFound(self))
        @uv.EISDIR => raise ErrorTrace::new(IsDirectory(self))
        error => raise error
      }
    })
  }
}

///|
pub impl Readable for Path with read(self : Path) -> Iter[@bytes.View] raise {
  self.read()
}

///|
pub async fn Path::write(
  self : Path,
  bytes : Iter[@bytes.View],
  loc~ : SourceLoc = _
) -> Unit raise {
  backtrace(loc~, fn() {
    let uv = uv()
    async_suspend_with_error(fn(resolve, reject : (Error) -> Unit) {
      try
        uv.fs_open(
          self.to_string(),
          @uv.OpenFlags::write_only(create=true, truncate=true),
          0o644,
          fn(file) {
            let file = File::File(file)
            async_run(fn() {
              try {
                file.write(bytes)
                uv.fs_close(file.inner(), fn() { resolve(()) }, fn(e) {
                  reject(e)
                })
                |> ignore()
              } catch {
                e => reject(e)
              }
            })
          },
          fn(e) { reject(e) },
        )
        |> ignore()
      catch {
        e => reject(e)
      }
    }) catch {
      @uv.ENOENT => raise ErrorTrace::new(FileSystemError::NotFound(self))
      @uv.EISDIR => raise ErrorTrace::new(IsDirectory(self))
      error => raise error
    }
  })
}

///|
pub impl Writable for Path with write(self : Path, bytes : Iter[@bytes.View]) -> Unit raise {
  self.write(bytes)
}

///|
pub async fn Path::iter(self : Path) -> Iter[Path] raise {
  let uv = uv()
  async_suspend_with_error(fn(
    resolve : (Iter[Path]) -> Unit,
    reject : (Error) -> Unit
  ) {
    try
      uv.fs_scandir(
        self.to_string(),
        0,
        fn(req) {
          let iter : Iter[Path] = fn(yield_) {
            try {
              while true {
                let dirent = req.next()
                let name = dirent.name
                yield_(self.join(name))
              }
            } catch {
              @uv.EOF => ()
              e => raise e
            }
          }
          resolve(iter)
        },
        fn(e) { reject(e) },
      )
      |> ignore()
    catch {
      e => reject(e)
    }
  })
}

///|
pub async fn Path::walk(self : Path, loc~ : SourceLoc = _) -> Iter[Path] raise {
  let uv = uv()
  fn(yield_) {
    backtrace(loc~, fn() {
      async_suspend_with_error(fn(resolve, reject) {
        try
          uv.fs_scandir(
            self.to_string(),
            0,
            fn(req) {
              async_run(fn() {
                try {
                  while true {
                    let dirent = req.next()
                    let type_ = dirent.type_
                    let name = dirent.name
                    let path = self.join(ToPath::to_path(name))
                    yield_(path)
                    if type_ is Dir {
                      path.walk().inner()(fn(path) { yield_(path) })
                    }
                  }
                } catch {
                  @uv.EOF => resolve(())
                  e => reject(e)
                }
              })
            },
            fn(e) { reject(e) },
          )
          |> ignore()
        catch {
          e => reject(e)
        }
      })
    })
  }
}

///|
type Stat @uv.Stat

///|
pub fn Stat::last_accessed(self : Stat) -> Int64 {
  self.inner().atim_sec()
}

///|
pub fn Stat::last_modified(self : Stat) -> Int64 {
  self.inner().mtim_sec()
}

///|
pub fn Stat::last_changed(self : Stat) -> Int64 {
  self.inner().ctim_sec()
}

///|
pub async fn Path::stat(self : Path, loc~ : SourceLoc = _) -> Stat raise {
  backtrace(loc~, fn() {
    try {
      let uv = uv()
      async_suspend_with_error(fn(resolve, reject) {
        try
          uv.fs_stat(self.to_string(), fn(stat) { resolve(Stat(stat)) }, fn(e) {
            reject(e)
          })
          |> ignore()
        catch {
          e => reject(e)
        }
      })
    } catch {
      error => raise error
    }
  })
}

///|
pub fn Stat::is_dir(self : Stat) -> Bool {
  self.inner().is_directory()
}

///|
pub fn Stat::is_directory(self : Stat) -> Bool {
  self.inner().is_directory()
}

///|
pub fn Stat::is_file(self : Stat) -> Bool {
  self.inner().is_file()
}

///|
pub fn Stat::is_regular(self : Stat) -> Bool {
  self.inner().is_file()
}

///|
pub fn Stat::type_(self : Stat) -> FileType {
  match self.inner().type_() {
    @uv.File => FileType::File
    @uv.Dir => FileType::Directory
    @uv.Link => FileType::Symlink
    @uv.Socket => FileType::Socket
    @uv.Fifo => FileType::Fifo
    @uv.Block => FileType::BlockDevice
    @uv.Char => FileType::CharacterDevice
    @uv.Unknown => FileType::Unknown
  }
}

///|
pub async fn Path::is_dir(self : Path, loc~ : SourceLoc = _) -> Bool raise {
  backtrace(loc~, fn() {
    let stat = self.stat()
    stat.is_dir()
  })
}

///|
pub async fn Path::is_file(self : Path) -> Bool raise {
  let stat = self.stat()
  stat.is_file()
}

///|
pub async fn Path::resolve(self : Path, loc~ : SourceLoc = _) -> Path raise {
  backtrace(loc~, fn() {
    let uv = uv()
    let self = self.to_path()
    if self.flavor != flavor.val {
      raise ErrorTrace::new(NotSupported(self.to_string()))
    }
    let resolved_parts = []
    for part in self.parts() {
      if part == ".." {
        resolved_parts.pop() |> ignore()
      } else {
        resolved_parts.push(part)
      }
    }
    let resolved_path = Path::{ ..self, parts: resolved_parts }
    async_suspend_with_error(fn(resolve, reject : (Error) -> Unit) {
      let reject = fn(error : Error) -> Unit {
        match error {
          @uv.ENOENT => reject(ErrorTrace::new(FileSystemError::NotFound(self)))
          @uv.ENOTDIR => reject(ErrorTrace::new(NotDirectory(self)))
          e => reject(e)
        }
      }
      try
        uv.fs_realpath(
          resolved_path.to_string(),
          fn(p) { resolve(Path::new(p)) },
          fn(e) { reject(e) },
        )
        |> ignore()
      catch {
        e => reject(e)
      }
    })
  })
}

///|
pub async fn[Target : ToPath] Path::copy_to(
  self : Path,
  target : Target,
  recursive~ : Bool = false,
  overwrite~ : Bool = false,
  loc~ : SourceLoc = _
) -> Unit raise {
  backtrace(loc~, fn() {
    let uv = uv()
    let target : Path = target.to_path()
    if self.is_dir() {
      if not(recursive) {
        raise ErrorTrace::new(IsDirectory(self))
      }
      if not(overwrite) && target.exists() {
        raise ErrorTrace::new(AlreadyExists(target))
      }
      target.mkdir()
      self
      .iter()
      .each(fn(entry) {
        let target_entry = target.join(entry.relative_to(self))
        entry.copy_to(target_entry, recursive~, overwrite~)
      })
    } else {
      async_suspend_with_error(fn(resolve, reject : (Error) -> Unit) {
        try
          uv.fs_copyfile(
            self.to_string(),
            target.to_string(),
            @uv.CopyFileFlags::new(allow_exists=overwrite),
            fn() { resolve(()) },
            fn(e) { reject(e) },
          )
          |> ignore()
        catch {
          e => reject(e)
        }
      })
    }
  })
}

///|
pub async fn[Target : ToPath] Path::move_to(
  self : Path,
  target : Target,
  loc~ : SourceLoc = _
) -> Unit raise {
  let uv = uv()
  backtrace(loc~, fn() {
    async_suspend_with_error(fn(resolve, reject : (Error) -> Unit) {
      try
        uv.fs_rename(
          self.to_string(),
          target.to_path().to_string(),
          fn() { resolve(()) },
          fn(e) { reject(e) },
        )
        |> ignore()
      catch {
        e => reject(e)
      }
    })
  })
}

///|
pub async fn Path::unlink(self : Path, loc~ : SourceLoc = _) -> Unit raise {
  let uv = uv()
  backtrace(loc~, fn() {
    async_suspend_with_error(fn(resolve, reject : (Error) -> Unit) {
      try
        uv.fs_unlink(self.to_string(), fn() { resolve(()) }, fn(e) { reject(e) })
        |> ignore()
      catch {
        e => reject(e)
      }
    }) catch {
      @uv.ENOENT => raise ErrorTrace::new(FileSystemError::NotFound(self))
      @uv.EISDIR => raise ErrorTrace::new(IsDirectory(self))
      error => raise error
    }
  })
}

///|
pub async fn Path::rmdir(self : Path, loc~ : SourceLoc = _) -> Unit raise {
  let uv = uv()
  backtrace(loc~, fn() {
    async_suspend_with_error(fn(resolve, reject : (Error) -> Unit) {
      try
        uv.fs_rmdir(self.to_string(), fn() { resolve(()) }, fn(e) { reject(e) })
        |> ignore()
      catch {
        e => reject(e)
      }
    }) catch {
      @uv.ENOTEMPTY => raise ErrorTrace::new(NotEmpty(self))
      @uv.ENOENT => raise ErrorTrace::new(FileSystemError::NotFound(self))
      error => raise error
    }
  })
}

///|
pub async fn Path::mkdir(
  self : Path,
  mode~ : Int = 0o777,
  loc~ : SourceLoc = _
) -> Unit raise {
  let uv = uv()
  backtrace(loc~, fn() {
    async_suspend_with_error(fn(resolve, reject : (Error) -> Unit) {
      try
        uv.fs_mkdir(self.to_string(), mode, fn() { resolve(()) }, fn(e) {
          reject(e)
        })
        |> ignore()
      catch {
        e => reject(e)
      }
    }) catch {
      @uv.EEXIST => raise ErrorTrace::new(AlreadyExists(self))
      error => raise error
    }
  })
}

///|
pub async fn Path::access(
  self : Path,
  read~ : Bool = false,
  write~ : Bool = false,
  execute~ : Bool = false,
  loc~ : SourceLoc = _
) -> Unit raise {
  let uv = uv()
  backtrace(loc~, fn() {
    async_suspend_with_error(fn(resolve, reject : (Error) -> Unit) {
      try
        uv.fs_access(
          self.to_string(),
          @uv.AccessFlags::new(read~, write~, execute~),
          fn() { resolve(()) },
          fn(e) { reject(e) },
        )
        |> ignore()
      catch {
        e => reject(e)
      }
    }) catch {
      @uv.ENOENT => raise ErrorTrace::new(FileSystemError::NotFound(self))
      error => raise error
    }
  })
}

///|
pub async fn Path::exists(self : Path, loc~ : SourceLoc = _) -> Bool raise {
  backtrace(loc~, fn() {
    try {
      self.access()
      true
    } catch {
      ErrorTrace(FileSystemError::NotFound(_), ..) => false
      error => raise error
    }
  })
}

///|
pub async fn Path::remove(
  self : Path,
  recursive~ : Bool = false,
  loc~ : SourceLoc = _
) -> Unit raise {
  backtrace(loc~, fn() {
    if self.is_dir() {
      let entries = self.iter().collect()
      if not(entries.is_empty()) {
        if not(recursive) {
          raise ErrorTrace::new(NotEmpty(self))
        }
        Scope::new(fn(scope) {
          for entry in entries {
            scope.launch(fn() { entry.remove(recursive~) })
          }
        })
      }
      self.rmdir()
    } else {
      self.unlink()
    }
  })
}

///|
pub async fn[R] with_temporary_directory(
  f : async (Path) -> R raise,
  loc~ : SourceLoc = _
) -> R raise {
  let uv = uv()
  let path = backtrace(loc~, () => async_suspend_with_error((resolve, reject) => try {
    let tmpdir = Path::new(@uv.os_tmpdir())
    uv.fs_mkdtemp(tmpdir.join("moonbit-XXXXXXXX").to_string(), resolve, reject)
    |> ignore()
  } catch {
    e => reject(e)
  }))
  let path = Path::new(path)
  try f(path) catch {
    error => {
      backtrace(loc~, fn() { path.remove(recursive=true) })
      raise error
    }
  } else {
    value => {
      backtrace(loc~, fn() { path.remove(recursive=true) })
      value
    }
  }
}

///|
pub fn Path::home() -> Path raise {
  Path::new(@uv.os_homedir())
}

///|
#deprecated("Use Path::cwd() instead")
pub fn cwd() -> Path raise {
  Path::new(@uv.cwd())
}

///|
pub fn Path::cwd() -> Path raise {
  Path::new(@uv.cwd())
}
