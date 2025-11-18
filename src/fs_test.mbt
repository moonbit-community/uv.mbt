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
  buffer : @buffer.Buffer,
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
  buffer : @buffer.Buffer,
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
test "open/directory" {
  let uv = @uv.Loop::new()
  let errors : Array[Error] = []
  uv.fs_open(
    b"test/fixtures",
    @uv.OpenFlags::read_only(directory=true),
    0,
    _ => (),
    errors.push(_),
  )
  |> ignore()
  uv.run(Default)
  uv.close()
  for error in errors {
    raise error
  }
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
  entries.sort_by_key(_.name())
  @assert.eq(entries[0].name(), "example.txt")
  @assert.t(entries[0].type_() is File)
  @assert.eq(entries[1].name(), ".gitattributes")
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
  @assert.n(stat.is_directory())
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
  @assert.t(sources is ["example.txt", ".gitattributes", ..])
}

///|
test "fs_fsync_sync" {
  let uv = @uv.Loop::new()
  let path : Bytes = "test-fsync-sync.txt"
  let file = uv.fs_open_sync(
    path,
    @uv.OpenFlags::write_only(create=true),
    0o644,
  )
  let data : Bytes = "Hello, fsync!"
  uv.fs_write_sync(file, [data])
  uv.fs_fsync_sync(file)
  uv.fs_close_sync(file)
  uv.fs_unlink_sync(path)
  uv.close()
}

///|
test "fs_fdatasync_sync" {
  let uv = @uv.Loop::new()
  let path : Bytes = "test-fdatasync-sync.txt"
  let file = uv.fs_open_sync(
    path,
    @uv.OpenFlags::write_only(create=true),
    0o644,
  )
  let data : Bytes = "Hello, fdatasync!"
  uv.fs_write_sync(file, [data])
  uv.fs_fdatasync_sync(file)
  uv.fs_close_sync(file)
  uv.fs_unlink_sync(path)
  uv.close()
}

///|
test "fs_fsync_async" {
  let uv = @uv.Loop::new()
  let errors : Array[Error] = []
  let mut synced = false
  let path : Bytes = "test-fsync-async.txt"
  let file = uv.fs_open_sync(
    path,
    @uv.OpenFlags::write_only(create=true),
    0o644,
  )
  let data : Bytes = "Hello, async fsync!"
  uv.fs_write_sync(file, [data])
  try
    uv.fs_fsync(file, () => synced = true, e => errors.push(e)) |> ignore()
  catch {
    e => errors.push(e)
  }
  uv.run(Default)
  @assert.t(synced)
  uv.fs_close_sync(file)
  uv.fs_unlink_sync(path)
  uv.close()
  for error in errors {
    raise error
  }
}

///|
test "fs_fdatasync_async" {
  let uv = @uv.Loop::new()
  let errors : Array[Error] = []
  let mut synced = false
  let path : Bytes = "test-fdatasync-async.txt"
  let file = uv.fs_open_sync(
    path,
    @uv.OpenFlags::write_only(create=true),
    0o644,
  )
  let data : Bytes = "Hello, async fdatasync!"
  uv.fs_write_sync(file, [data])
  try
    uv.fs_fdatasync(file, () => synced = true, e => errors.push(e)) |> ignore()
  catch {
    e => errors.push(e)
  }
  uv.run(Default)
  @assert.t(synced)
  @assert.t(errors.is_empty())
  uv.fs_close_sync(file)
  uv.fs_unlink_sync(path)
  uv.close()
  for error in errors {
    raise error
  }
}

///|
test "fs_link_sync" {
  let uv = @uv.Loop::new()
  let original_file : Bytes = "test/fixtures/example.txt"
  let link_file : Bytes = "test-link-sync.txt"
  uv.fs_link_sync(original_file, link_file)
  // Verify the link exists and points to the same file
  let original_stat = uv.fs_stat_sync(original_file)
  let link_stat = uv.fs_stat_sync(link_file)
  @assert.eq(original_stat.ino(), link_stat.ino()) // Same inode
  @assert.t(link_stat.is_file())
  // Clean up
  uv.fs_unlink_sync(link_file)
  uv.close()
}

///|
test "fs_link_async" {
  let uv = @uv.Loop::new()
  let errors : Array[Error] = []
  let mut linked = false
  let original_file : Bytes = "test/fixtures/example.txt"
  let link_file : Bytes = "test-link-async.txt"
  try
    uv.fs_link(
      original_file,
      link_file,
      () => {
        linked = true
        uv.fs_unlink_sync(link_file) catch {
          e => errors.push(e)
        }
      },
      e => errors.push(e),
    )
    |> ignore()
  catch {
    e => errors.push(e)
  }
  uv.run(Default)
  @assert.t(linked)
  for error in errors {
    raise error
  }
  uv.close()
}

///|
test "fs_symlink_sync" {
  let uv = @uv.Loop::new()
  let target_file : Bytes = "test/fixtures/example.txt"
  let symlink_file : Bytes = "test-symlink-sync.txt"
  uv.fs_symlink_sync(target_file, symlink_file, @uv.SymlinkFlags::new())
  // Verify the symlink exists
  let stat = uv.fs_lstat_sync(symlink_file)
  @assert.t(stat.is_symlink())
  // Clean up
  uv.fs_unlink_sync(symlink_file)
  uv.close()
}

///|
test "fs_symlink_async" {
  let uv = @uv.Loop::new()
  let mut error : @uv.Errno? = None
  let mut symlinked = false
  let target_file : Bytes = "test/fixtures/example.txt"
  let symlink_file : Bytes = "test-symlink-async.txt"
  try
    uv.fs_symlink(
      target_file,
      symlink_file,
      @uv.SymlinkFlags::new(),
      () => {
        symlinked = true
        uv.fs_unlink_sync(symlink_file) catch {
          e => error = Some(e)
        }
      },
      e => error = Some(e),
    )
    |> ignore()
  catch {
    e => error = Some(e)
  }
  uv.run(Default)
  @assert.t(symlinked)
  @assert.t(error is None)
  uv.close()
}

///|
test "fs_readlink_sync" {
  let uv = @uv.Loop::new()
  let target_file : Bytes = "test/fixtures/example.txt"
  let symlink_file : Bytes = "test-readlink-sync.txt"
  // Create a symlink first
  uv.fs_symlink_sync(target_file, symlink_file, @uv.SymlinkFlags::new())
  // Read the symlink target
  let target = uv.fs_readlink_sync(symlink_file)
  @assert.eq(target, target_file)
  // Clean up
  uv.fs_unlink_sync(symlink_file)
  uv.close()
}

///|
test "fs_readlink_async" {
  let uv = @uv.Loop::new()
  let mut error : Error? = None
  let mut target_read : Bytes? = None
  let target_file : Bytes = "test/fixtures/example.txt"
  let symlink_file : Bytes = "test-readlink-async.txt"
  // Create a symlink first
  uv.fs_symlink_sync(target_file, symlink_file, @uv.SymlinkFlags::new())
  // Read the symlink target asynchronously
  try
    uv.fs_readlink(
      symlink_file,
      target => {
        target_read = Some(target)
        try {
          @assert.eq(target, target_file)
          uv.fs_unlink_sync(symlink_file)
        } catch {
          e => error = Some(e)
        }
      },
      e => error = Some(e),
    )
    |> ignore()
  catch {
    e => error = Some(e)
  }
  uv.run(Default)
  @assert.t(target_read is Some(_))
  @assert.t(error is None)
  uv.close()
}

///|
test "fs_lstat_sync" {
  guard @uv.os_uname().sysname() != "Windows_NT" else {
    // Windows doesn't support symlink creation without elevated privileges
    return
  }
  let uv = @uv.Loop::new()
  let target_file : Bytes = "test/fixtures/example.txt"
  let symlink_file : Bytes = "test-lstat-sync.txt"
  // Create a symlink first
  uv.fs_symlink_sync(target_file, symlink_file, @uv.SymlinkFlags::new())
  // Use lstat to get info about the symlink itself
  let symlink_stat = uv.fs_lstat_sync(symlink_file)
  @assert.t(symlink_stat.is_symlink())
  @assert.t(not(symlink_stat.is_file()))
  // Compare with regular stat which follows the link
  let target_stat = uv.fs_stat_sync(symlink_file)
  @assert.t(target_stat.is_file())
  @assert.t(not(target_stat.is_symlink()))
  // Clean up
  uv.fs_unlink_sync(symlink_file)
  uv.close()
}

///|
test "fs_statfs" {
  let uv = @uv.Loop::new()
  let errors : Array[Error] = []
  uv.fs_statfs("/", stat => ignore(stat.get_type()), error => errors.push(error))
  |> ignore()
  uv.run(Default)
  for error in errors {
    raise error
  }
  uv.close()
}

///|
test "fs_rename_sync" {
  let uv = @uv.Loop::new()
  let original_file : Bytes = "test-rename-sync-original.txt"
  let renamed_file : Bytes = "test-rename-sync-renamed.txt"

  // Create a test file first
  let file = uv.fs_open_sync(
    original_file,
    @uv.OpenFlags::write_only(create=true),
    0o644,
  )
  let data : Bytes = "Hello, rename sync!"
  uv.fs_write_sync(file, [data])
  uv.fs_close_sync(file)

  // Verify the original file exists
  let original_stat = uv.fs_stat_sync(original_file)
  @assert.t(original_stat.is_file())

  // Rename the file
  uv.fs_rename_sync(original_file, renamed_file)

  // Verify the renamed file exists and has the same content
  let renamed_stat = uv.fs_stat_sync(renamed_file)
  @assert.t(renamed_stat.is_file())
  @assert.eq(renamed_stat.size(), original_stat.size())

  // Verify the original file no longer exists
  let mut original_file_exists = true
  try uv.fs_stat_sync(original_file) |> ignore() catch {
    _ => original_file_exists = false // Expected: file should not exist
  }
  @assert.n(original_file_exists)

  // Verify the renamed file has the correct content
  let read_file = uv.fs_open_sync(renamed_file, @uv.OpenFlags::read_only(), 0)
  let buffer = Bytes::make(data.length(), 0)
  let count = uv.fs_read_sync(read_file, [buffer])
  uv.fs_close_sync(read_file)
  @assert.eq(count, data.length())
  @assert.eq(buffer[:count], data)

  // Clean up
  uv.fs_unlink_sync(renamed_file)
  uv.close()
}
