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
pub async fn File::close(self : File) -> Unit raise {
  let uv = uv()
  suspend(fn(resolve, reject : (Error) -> Unit) {
    try
      uv.fs_close(self.inner(), fn() { resolve(()) }, fn(e) { reject(e) })
      |> ignore()
    catch {
      e => reject(e)
    }
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
    yield_ : (@bytes.View) -> IterResult,
    resolve : (IterResult) -> Unit,
    reject : (Error) -> Unit,
  ) -> Unit {
    let bytes = Bytes::make(256, 0)
    try
      uv.fs_read(
        file,
        [bytes[:]],
        fn(count) {
          if count == 0 {
            resolve(IterContinue)
          } else {
            match yield_(bytes[:count]) {
              IterEnd => resolve(IterEnd)
              IterContinue => read(uv, file, yield_, resolve, reject)
            }
          }
        },
        reject(_),
      )
      |> ignore()
    catch {
      e => reject(e)
    }
  }

  let uv = uv()
  suspend(fn(resolve, reject) {
    resolve(
      Iter::new(fn(yield_) {
        suspend(fn(resolve, reject) {
          read(uv, self.inner(), yield_, resolve, reject)
        }) catch {
          e => {
            reject(e)
            IterEnd
          }
        }
      }),
    )
  })
}

///|
pub impl Writable for File with write(self : File, bytes : Iter[@bytes.View]) {
  fn write(
    uv : @uv.Loop,
    file : @uv.File,
    bytes : @bytes.View,
    resolve : (Unit) -> Unit,
    reject : (Error) -> Unit,
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
        reject(_),
      )
      |> ignore()
    catch {
      e => reject(e)
    }
  }

  let uv = uv()
  for bytes in bytes {
    suspend(fn(resolve, reject) {
      write(uv, self.inner(), bytes, resolve, reject)
    })
  }
}

///|
pub async fn Path::open(self : Path) -> File raise {
  let uv = uv()
  suspend(fn(resolve, reject) {
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
  })
}

///|
pub fn Path::write(self : Path, bytes : Iter[@bytes.View]) -> Unit raise {
  let uv = uv()
  suspend(fn(resolve, reject) {
    try
      uv.fs_open(
        self.to_string(),
        @uv.OpenFlags::write_only(create=true, truncate=true),
        0o644,
        fn(file) {
          let file = File::File(file)
          file.write(bytes) catch {
            e => reject(e)
          }
          try
            uv.fs_close(file.inner(), fn() { resolve(()) }, fn(e) { reject(e) })
            |> ignore()
          catch {
            e => reject(e)
          }
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
pub impl Writable for Path with write(self : Path, bytes : Iter[@bytes.View]) -> Unit raise {
  self.write(bytes)
}

///|
pub fn Path::iter(self : Path) -> Iter[Path] raise {
  let uv = uv()
  suspend(fn(resolve : (Iter[Path]) -> Unit, reject : (Error) -> Unit) {
    try
      uv.fs_scandir(
        self.to_string(),
        0,
        fn(req) {
          let iter = Iter::new(fn(yield_) {
            while true {
              let dirent = req.next() catch {
                @uv.EOF => break IterContinue
                error => {
                  reject(error)
                  break IterEnd
                }
              }
              let name = dirent.name
              println("Found entry: \{name}")
              match yield_(self.join(name)) {
                IterEnd => break IterEnd
                IterContinue => ()
              }
            } else {
              IterContinue
            }
          })
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
pub fn Path::stat(self : Path) -> Stat raise {
  let uv = uv()
  suspend(fn(resolve, reject) {
    try
      uv.fs_stat(self.to_string(), fn(stat) { resolve(Stat(stat)) }, fn(e) {
        reject(e)
      })
      |> ignore()
    catch {
      e => reject(e)
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
pub fn Path::is_dir(self : Path) -> Bool raise {
  let stat = self.stat()
  stat.is_dir()
}

///|
pub async fn Path::is_file(self : Path) -> Bool raise {
  let stat = self.stat()
  stat.is_file()
}

///|
pub async fn Path::resolve(self : Path) -> Path raise {
  let uv = uv()
  let self = self.to_path()
  if self.flavor != flavor.val {
    raise @uv.ENOSYS
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
  suspend(fn(resolve, reject : (Error) -> Unit) {
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
}

///|
pub fn[Target : ToPath] Path::copy_to(
  self : Path,
  target : Target,
  recursive~ : Bool = false,
  overwrite~ : Bool = false,
) -> Unit raise {
  let uv = uv()
  let target : Path = target.to_path()
  if self.is_dir() {
    if not(recursive) {
      raise @uv.EISDIR
    }
    if not(overwrite) && target.exists() {
      raise @uv.EEXIST
    }
    target.mkdir()
    self
    .iter()
    .each(fn(entry) {
      let target_entry = target.join(entry.relative_to(self))
      entry.copy_to(target_entry, recursive~, overwrite~)
    })
  } else {
    suspend(fn(resolve, reject : (Error) -> Unit) {
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
}

///|
pub async fn[Target : ToPath] Path::move_to(
  self : Path,
  target : Target,
) -> Unit raise {
  let uv = uv()
  suspend(fn(resolve, reject : (Error) -> Unit) {
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
}

///|
pub fn Path::unlink(self : Path) -> Unit raise {
  let uv = uv()
  suspend(fn(resolve, reject : (@uv.Errno) -> Unit) {
    try
      uv.fs_unlink(self.to_string(), () => resolve(()), e => reject(e))
      |> ignore()
    catch {
      e => reject(e)
    }
  })
}

///|
pub fn Path::rmdir(self : Path) -> Unit raise {
  let uv = uv()
  suspend(fn(resolve, reject : (@uv.Errno) -> Unit) {
    try
      uv.fs_rmdir(self.to_string(), fn() { resolve(()) }, fn(e) { reject(e) })
      |> ignore()
    catch {
      e => reject(e)
    }
  })
}

///|
pub fn Path::mkdir(self : Path, mode~ : Int = 0o777) -> Unit raise {
  let uv = uv()
  suspend(fn(resolve, reject : (@uv.Errno) -> Unit) {
    try
      uv.fs_mkdir(self.to_string(), mode, fn() { resolve(()) }, fn(e) {
        reject(e)
      })
      |> ignore()
    catch {
      e => reject(e)
    }
  })
}

///|
pub fn Path::access(
  self : Path,
  read~ : Bool = false,
  write~ : Bool = false,
  execute~ : Bool = false,
) -> Unit raise {
  let uv = uv()
  suspend(fn(resolve, reject : (@uv.Errno) -> Unit) {
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
  })
}

///|
pub fn Path::exists(self : Path) -> Bool raise {
  try {
    self.access()
    true
  } catch {
    @uv.ENOENT => false
    error => raise error
  }
}

///|
pub fn Path::remove(self : Path, recursive~ : Bool = false) -> Unit raise {
  if self.is_dir() {
    let entries = self.iter().collect()
    if not(entries.is_empty()) {
      if not(recursive) {
        raise @uv.ENOTEMPTY
      }
      for entry in entries {
        entry.remove(recursive~)
      }
    }
    self.rmdir()
  } else {
    self.unlink()
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
