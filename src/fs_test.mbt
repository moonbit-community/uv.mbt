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
fn test_close(uv : @uv.Loop, file : @uv.File, error : Ref[Errno?]) -> Unit {
  try uv.fs_close(file, () => (), e => error.val = Some(e)) |> ignore() catch {
    e => error.val = Some(e)
  }
}

///|
fn test_write(
  uv : @uv.Loop,
  file : @uv.File,
  buffer : @buffer.T,
  bytes : Bytes,
  start : Int,
  count : Int,
  error : Ref[Errno?],
) -> Unit {
  buffer.write_bytesview(bytes[start:start + count])
  test_read(uv, file, buffer, bytes, error)
}

///|
fn test_read(
  uv : @uv.Loop,
  file : @uv.File,
  buffer : @buffer.T,
  bytes : Bytes,
  error : Ref[Errno?],
) -> Unit {
  try
    uv.fs_read(
      file,
      [bytes[:]],
      count => if count == 0 {
        test_close(uv, file, error)
      } else {
        test_write(uv, file, buffer, bytes, 0, count, error)
      },
      errno => {
        error.val = Some(errno)
        test_close(uv, file, error)
      },
    )
    |> ignore()
  catch {
    e => {
      error.val = Some(e)
      test_close(uv, file, error)
    }
  }
}

///|
test "open" {
  let uv = @uv.Loop::new()
  let errors : Array[Error] = []
  uv.fs_open(
    b"test/fixtures/example.txt",
    @uv.OpenFlags::read_only(),
    0,
    _ => (),
    errors.push(_),
  )
  |> ignore()
  uv.run(Default)
  uv.close()
}

///|
test "open/sync" {
  let uv = @uv.Loop::new()
  uv.fs_open_sync(b"test/fixtures/example.txt", @uv.OpenFlags::read_only(), 0)
  |> ignore()
  uv.close()
}

///|
test "read" {
  let uv = @uv.Loop::new()
  let error = Ref::new(None)
  let buffer = @buffer.new()
  uv.fs_open(
    b"test/fixtures/example.txt",
    @uv.OpenFlags::read_only(),
    0,
    file => test_read(uv, file, buffer, Bytes::make(1024, 0), error),
    e => error.val = Some(e),
  )
  |> ignore()
  uv.run(Default)
  uv.close()
  if error.val is Some(error) {
    raise error
  }
  @assert.eq(buffer.contents(), "Hello, world!\n")
}

///|
test "read/sync" {
  let uv = @uv.Loop::new()
  let file = uv.fs_open_sync(
    b"test/fixtures/example.txt",
    @uv.OpenFlags::read_only(),
    0,
  )
  let buffer = @buffer.new()
  let bytes = Bytes::make(1024, 0)
  for count = uv.fs_read_sync(file, [bytes])
      count > 0
      count = uv.fs_read_sync(file, [bytes]) {
    buffer.write_bytesview(bytes[:count])
  }
  @assert.eq(buffer.contents(), "Hello, world!\n")
  uv.close()
}

///|
test "mkdir" {
  let uv = @uv.Loop::new()
  let errors : Array[Error] = []
  uv.fs_mkdir(
    "test-dir",
    0,
    fn() {
      try
        uv.fs_rmdir("test-dir", () => (), e => errors.push(e)) |> ignore()
      catch {
        e => errors.push(e)
      }
    },
    e => errors.push(e),
  )
  |> ignore()
  uv.run(Default)
  uv.stop()
  uv.close()
  for e in errors {
    raise e
  }
}

///|
test "scandir" {
  let uv = @uv.Loop::new()
  let mut error = None
  let entries = []
  uv.fs_scandir(
    "test/fixtures",
    0,
    scandir => while true {
      let dirent = scandir.next() catch {
        e => {
          if not(e is EOF) {
            error = Some(e)
          }
          break
        }
      }
      entries.push(dirent)
    },
    e => if not(e is EOF) { error = Some(e) },
  )
  |> ignore()
  uv.run(Default)
  uv.stop()
  uv.close()
  @assert.eq(entries[0].name(), ".gitattributes")
  @assert.t(entries[0].type_() is File)
  @assert.eq(entries[1].name(), "example.txt")
  @assert.t(entries[1].type_() is File)
  if error is Some(e) {
    raise e
  }
}

///|
test "copyfile_unlink" {
  let uv = @uv.Loop::new()
  let mut error = None
  uv.fs_copyfile(
    "test/fixtures/example.txt",
    "test/fixtures/example-copy.txt",
    @uv.CopyFileFlags::new(),
    fn() {
      try
        uv.fs_unlink("test/fixtures/example-copy.txt", fn() {  }, fn(e) {
          error = Some(e)
        })
        |> ignore()
      catch {
        e => error = Some(e)
      }
    },
    e => error = Some(e),
  )
  |> ignore()
  uv.run(Default)
  uv.stop()
  uv.close()
  if error is Some(e) {
    raise e
  }
}

///|
test "realpath" {
  let uv = @uv.Loop::new()
  let cwd = @uv.cwd()
  let errors : Array[Error] = []
  let file : Bytes = "test/fixtures/example.txt"
  uv.fs_realpath(
    file,
    p => @assert.eq(p[:cwd.length()], cwd) catch { e => errors.push(e) },
    e => errors.push(e),
  )
  |> ignore()
  uv.run(Default)
  uv.close()
  for e in errors {
    raise e
  }
}

///|
test "stat" {
  let uv = @uv.Loop::new()
  let errors : Array[Error] = []
  uv.fs_stat(
    "test/fixtures/example.txt",
    stat => try {
      @assert.t(stat.is_file())
      @assert.t(not(stat.is_directory()))
      @assert.eq(stat.size(), 14)
    } catch {
      e => errors.push(e)
    },
    e => errors.push(e),
  )
  |> ignore()
  uv.run(Default)
  uv.stop()
  uv.close()
  for e in errors {
    raise e
  }
}

///|
test "stat/sync" {
  let uv = @uv.Loop::new()
  let stat = uv.fs_stat_sync("test/fixtures/example.txt")
  uv.close()
  @assert.t(stat.is_file())
  @assert.not(stat.is_directory())
}

///|
test "lstat" {
  let uv = @uv.Loop::new()
  let errors : Array[Error] = []
  uv.fs_lstat(
    "test/fixtures",
    stat => try {
      // It should be a directory
      @assert.t(stat.is_directory())
      // It shouldn't be a regular file
      @assert.t(not(stat.is_file()))
    } catch {
      e => errors.push(e)
    },
    e => errors.push(e),
  )
  |> ignore()
  uv.run(Default)
  uv.stop()
  uv.close()
  for e in errors {
    raise e
  }
}

///|
test "fstat" {
  let uv = @uv.Loop::new()
  let errors : Array[Error] = []
  let mut file_handle : @uv.File? = None
  uv.fs_open(
    "test/fixtures/example.txt",
    @uv.OpenFlags::read_only(),
    0,
    file => file_handle = Some(file),
    e => errors.push(e),
  )
  |> ignore()
  uv.run(Default)
  if file_handle is Some(fh) {
    uv.fs_fstat(
      fh,
      stat => try {
        // It should be a regular file
        @assert.t(stat.is_file())
        // It shouldn't be a directory
        @assert.t(not(stat.is_directory()))
        // Size should be greater than 0
        @assert.t(stat.size() > 0)
      } catch {
        e => errors.push(e)
      },
      e => errors.push(e),
    )
    |> ignore()
    uv.run(Default)
    uv.fs_close(fh, () => (), e => errors.push(e)) |> ignore()
    uv.run(Default)
  }
  uv.stop()
  uv.close()
  for e in errors {
    raise e
  }
}

///|
test "fs_mkdtemp" {
  let uv = @uv.Loop::new()
  let mut error : Error? = None
  let template : Bytes = "test-dir-XXXXXX"
  uv.fs_mkdtemp(
    template,
    path => try {
      @assert.t(path is [.. "test-dir-", ..])
      let stat = uv.fs_stat_sync(path)
      @assert.t(stat.is_directory())
      uv.fs_rmdir_sync(path)
    } catch {
      e => error = Some(e)
    },
    e => error = Some(e),
  )
  |> ignore()
  uv.run(Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
}

///|
test "fs_mkdtemp_sync" {
  let uv = @uv.Loop::new()
  let template : Bytes = "test-dir-XXXXXX"
  let path = uv.fs_mkdtemp_sync(template)
  @assert.t(path is [.. "test-dir-", ..])
  let stat = uv.fs_stat_sync(path)
  @assert.t(stat.is_directory())
  uv.fs_rmdir_sync(path)
  uv.close()
}

///|
test "fs_mkstemp" {
  let uv = @uv.Loop::new()
  let mut error : Error? = None
  let template : Bytes = "test-file-XXXXXX"
  uv.fs_mkstemp(
    template,
    path => try {
      @assert.t(path is [.. "test-file-", ..])
      let stat = uv.fs_stat_sync(path)
      @assert.t(stat.is_file())
      uv.fs_unlink_sync(path)
    } catch {
      e => error = Some(e)
    },
    e => error = Some(e),
  )
  |> ignore()
  uv.run(Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
}

///|
test "fs_mkstemp_sync" {
  let uv = @uv.Loop::new()
  let template : Bytes = "test-file-XXXXXX"
  let path = uv.fs_mkstemp_sync(template)
  @assert.t(path is [.. "test-file-", ..])
  let stat = uv.fs_stat_sync(path)
  @assert.t(stat.is_file())
  uv.fs_unlink_sync(path)
  uv.close()
}

///|
test "opendir-readdir-closedir" {
  let uv = @uv.Loop::new()
  let mut error : Error? = None
  let sources = []
  fn error_cb(e : @uv.Errno) {
    error = Some(e)
  }

  fn read_cb(dir : @uv.Dir, dirents : Array[@uv.Dirent]) {
    if dirents.is_empty() {
      try uv.fs_closedir(dir, () => (), error_cb) |> ignore() catch {
        e => error = Some(e)
      }
      return
    }
    for dirent in dirents {
      guard dirent.type_() is File else { continue }
      let name = dirent.name()
      sources.push(name)
    }
    try uv.fs_readdir(dir, 1, read_cb(dir, _), error_cb) |> ignore() catch {
      e => error = Some(e)
    }
  }

  fn open_cb(dir) {
    try uv.fs_readdir(dir, 1, read_cb(dir, _), error_cb) |> ignore() catch {
      e => error = Some(e)
    }
  }

  try uv.fs_opendir("test/fixtures", open_cb, error_cb) |> ignore() catch {
    e => error = Some(e)
  }
  uv.run(Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
  sources.sort()
  @assert.eq(sources, ["example.txt", ".gitattributes"])
}
