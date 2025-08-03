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
type Fs

///|
pub impl ToReq for Fs with to_req(self : Fs) -> Req = "%identity"

///|
extern "c" fn uv_fs_make() -> Fs = "moonbit_uv_fs_make"

///|
extern "c" fn uv_fs_req_cleanup(req : Fs) = "moonbit_uv_fs_req_cleanup"

///|
struct OpenFlags(Int)

///|
/// Creates file open flags for read-only access.
///
/// Returns an `OpenFlags` instance configured for read-only file access. Files
/// opened with these flags can only be read from, not written to or modified.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let flags = @uv.OpenFlags::read_only()
/// let file = uv.fs_open_sync("README.md", flags, 0o644)
/// uv.fs_close_sync(file)
/// uv.close()
/// ```
pub fn OpenFlags::read_only() -> OpenFlags {
  _O_RDONLY
}

///|
/// Creates file open flags for write-only access with configurable behaviors.
///
/// Parameters:
///
/// * `append` : Whether to append to the file instead of overwriting. When
///   `true`, writes will be positioned at the end of the file. Defaults to
///   `false`.
/// * `create` : Whether to create the file if it doesn't exist. When `true`, a
///   new file will be created if the specified path doesn't exist. Defaults to
///   `false`.
/// * `truncate` : Whether to truncate the file to zero length when opening.
///   When `true`, any existing content will be discarded. Defaults to `false`.
/// * `exclusive` : Whether to fail if the file already exists when creating.
///   When `true` and `create` is also `true`, the operation will fail if the
///   file already exists. Defaults to `false`.
///
/// Returns an `OpenFlags` instance configured for write-only access with the
/// specified behaviors.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// // Create a new file for writing, truncate if it exists
/// let flags = @uv.OpenFlags::write_only(create=true, truncate=true)
/// let path : Bytes = "output.txt"
/// let file = uv.fs_open_sync(path, flags, 0o644)
/// uv.fs_close_sync(file)
/// uv.fs_unlink_sync(path)
/// uv.close()
/// ```
pub fn OpenFlags::write_only(
  append~ : Bool = false,
  create~ : Bool = false,
  truncate~ : Bool = false,
  exclusive~ : Bool = false,
) -> OpenFlags {
  let mut flags = _O_WRONLY
  if append {
    flags = flags | _O_APPEND
  }
  if create {
    flags = flags | _O_CREAT
  }
  if truncate {
    flags = flags | _O_TRUNC
  }
  if exclusive {
    flags = flags | _O_EXCL
  }
  flags
}

///|
/// Creates file open flags for read-write access with configurable behaviors.
///
/// Parameters:
///
/// * `append` : Whether to append to the file instead of overwriting. When
///   `true`, writes will be positioned at the end of the file. Defaults to
///   `false`.
/// * `create` : Whether to create the file if it doesn't exist. When `true`, a
///   new file will be created if the specified path doesn't exist. Defaults to
///   `false`.
/// * `truncate` : Whether to truncate the file to zero length when opening. When
///   `true`, any existing content will be discarded. Defaults to `false`.
/// * `exclusive` : Whether to fail if the file already exists when creating.
///   When `true` and `create` is also `true`, the operation will fail if the
///   file already exists. Defaults to `false`.
///
/// Returns an `OpenFlags` instance configured for read-write access with the
/// specified behaviors.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// // Create a new file for reading and writing, fail if it exists
/// let flags = @uv.OpenFlags::read_write(create=true, exclusive=true)
/// let path : Bytes = "new_file.txt"
/// let file = uv.fs_open_sync(path, flags, 0o644)
/// uv.fs_close_sync(file)
/// uv.fs_unlink_sync(path)
/// uv.close()
/// ```
pub fn OpenFlags::read_write(
  append~ : Bool = false,
  create~ : Bool = false,
  truncate~ : Bool = false,
  exclusive~ : Bool = false,
) -> OpenFlags {
  let mut flags = _O_RDWR
  if append {
    flags = flags | _O_APPEND
  }
  if create {
    flags = flags | _O_CREAT
  }
  if truncate {
    flags = flags | _O_TRUNC
  }
  if exclusive {
    flags = flags | _O_EXCL
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
extern "c" fn uv_fs_O_TRUNC() -> Int = "moonbit_uv_fs_O_TRUNC"

///|
let _O_TRUNC : Int = uv_fs_O_TRUNC()

///|
extern "c" fn uv_fs_O_APPEND() -> Int = "moonbit_uv_fs_O_APPEND"

///|
let _O_APPEND : Int = uv_fs_O_APPEND()

///|
extern "c" fn uv_fs_O_EXCL() -> Int = "moonbit_uv_fs_O_EXCL"

///|
let _O_EXCL : Int = uv_fs_O_EXCL()

///|
extern "c" fn uv_fs_open(
  uv : Loop,
  req : Fs,
  path : Bytes,
  flags : Int,
  mode : Int,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_open"

///|
/// Asynchronously opens a file at the specified path with the given flags and
/// mode.
///
/// This function initiates a file open operation that will be handled
/// asynchronously by the event loop. When the operation completes, either the
/// success callback or error callback will be invoked depending on the result.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `path` : The file path to open as a `Bytes` object. If you have a
///   `String`, `@string.View`, or `@bytes.View`, convert it to `Bytes` first
///   using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `flags` : The file access mode and behavior flags. Use
///   `OpenFlags::read_only()`, `OpenFlags::write_only()`, or
///   `OpenFlags::read_write()` with optional parameters for additional
///   behaviors like append, create, truncate, or exclusive access.
/// * `mode` : The file permissions to use when creating a new file (octal
///   notation, e.g., `0o644`). This parameter is ignored if the file already
///   exists.
/// * `open_cb` : Success callback function that receives the filesystem request
///   handle and the opened file descriptor when the operation succeeds.
/// * `error_cb` : Error callback function that receives the filesystem request
///   handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid parameters or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = Loop::new()
/// uv.fs_open(
///   "README.md",
///   OpenFlags::read_only(),
///   0o644,
///   (file) => uv.fs_close_sync(file) catch { _ => () },
///   (error) => println("Failed to open file: \{error}"),
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// ```
pub fn Loop::fs_open(
  self : Loop,
  path : Bytes,
  flags : OpenFlags,
  mode : Int,
  open_cb : (File) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let result = req.result().to_int()
    uv_fs_req_cleanup(req)
    if result < 0 {
      error_cb(Errno::of_int(result))
    } else {
      open_cb(File(result))
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_open(self, req, path, flags.inner(), mode, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_open_sync(
  uv : Loop,
  req : Fs,
  path : Bytes,
  flags : Int,
  mode : Int,
) -> Int = "moonbit_uv_fs_open_sync"

///|
/// Synchronously opens a file at the specified path with the given flags and
/// mode.
///
/// This function blocks the current thread until the file open operation
/// completes. Unlike the asynchronous `fs_open` function, this operation does
/// not require callbacks and returns the file descriptor immediately upon
/// successful completion.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `path` : The file path to open as a `Bytes` object. If you have a
///   `String`, `@string.View`, or `@bytes.View`, convert it to `Bytes` first
///   using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `flags` : The file access mode and behavior flags. Use
///   `OpenFlags::read_only()`, `OpenFlags::write_only()`, or
///   `OpenFlags::read_write()` with optional parameters for additional behaviors
///   like append, create, truncate, or exclusive access.
/// * `mode` : The file permissions to use when creating a new file (octal
///   notation, e.g., `0o644`). This parameter is ignored if the file already
///   exists.
///
/// Returns a `File` handle that can be used for subsequent file operations like
/// reading, writing, or closing.
///
/// Throws an error of type `Errno` if the file cannot be opened (e.g., file does
/// not exist, insufficient permissions, invalid path, or system resource
/// exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let file = uv.fs_open_sync("README.md", @uv.OpenFlags::read_only(), 0o644)
/// uv.fs_close_sync(file)
/// uv.close()
/// ```
pub fn Loop::fs_open_sync(
  self : Loop,
  path : Bytes,
  flags : OpenFlags,
  mode : Int,
) -> File raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_open_sync(self, req, path, flags.inner(), mode)
  if status < 0 {
    raise Errno::of_int(status)
  }
  File(status)
}

///|
extern "c" fn uv_fs_close(
  uv : Loop,
  req : Fs,
  file : File,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_close"

///|
/// Asynchronously closes a file descriptor.
///
/// This function initiates a file close operation that will be handled
/// asynchronously by the event loop. When the operation completes, either the
/// success callback or error callback will be invoked depending on the result.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `file` : The file descriptor to close, typically obtained from `fs_open` or
///   `fs_open_sync`.
/// * `close_cb` : Success callback function that receives the filesystem request
///   handle when the file is closed successfully.
/// * `error_cb` : Error callback function that receives the filesystem request
///   handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid file descriptor or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = Loop::new()
/// let file = uv.fs_open_sync("README.md", OpenFlags::read_only(), 0o644)
/// uv.fs_close(
///   file,
///   fn() { println("File closed successfully") },
///   fn(error) { println("Failed to close file: \{error}") }
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// ```
pub fn Loop::fs_close(
  self : Loop,
  file : File,
  close_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let result = req.result()
    uv_fs_req_cleanup(req)
    if result < 0 {
      error_cb(Errno::of_int(result.to_int()))
    } else {
      close_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_close(self, req, file, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_close_sync(uv : Loop, req : Fs, file : File) -> Int = "moonbit_uv_fs_close_sync"

///|
pub fn Loop::fs_close_sync(self : Loop, file : File) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_close_sync(self, req, file)
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
struct File(Int)

///|
pub fn File::of_int(fd : Int) -> File {
  File(fd)
}

///|
pub fn File::to_int(self : File) -> Int {
  self.inner()
}

///|
extern "c" fn uv_fs_read(
  uv : Loop,
  req : Fs,
  file : File,
  bufs_base : FixedArray[Bytes],
  bufs_offset : FixedArray[Int],
  bufs_length : FixedArray[Int],
  offset : Int64,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_read"

///|
/// Asynchronously reads data from a file into multiple buffers.
///
/// This function initiates a read operation that will be handled asynchronously
/// by the event loop. The data is read from the file into the provided array of
/// byte views, which can be used for scatter-gather I/O operations. When the
/// operation completes, either the success callback or error callback will be
/// invoked depending on the result.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `file` : The file descriptor to read from, typically obtained from
/// `fs_open` or `fs_open_sync`.
/// * `bufs` : An array of byte views that will receive the data read from the
/// file. The views define both the memory locations and the amount of data to
/// read into each buffer.
/// * `offset` : The file position to start reading from. If `-1` (default),
/// reads from the current file position. Otherwise, reads from the specified
/// absolute position in the file.
/// * `read_cb` : Success callback function that receives the filesystem request
/// handle and the number of bytes actually read when the operation succeeds.
/// * `error_cb` : Error callback function that receives the filesystem request
/// handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid file descriptor or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// uv.fs_read(
///   @uv.stdin(),
///   [Bytes::make(100, 0)],
///   fn(bytes_read) { println("Read \{bytes_read} bytes") },
///   fn(error) { println("Error: \{error}") }
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// ```
pub fn Loop::fs_read(
  self : Loop,
  file : File,
  bufs : Array[@bytes.View],
  offset~ : Int64 = -1,
  read_cb : (Int) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let result = req.result()
    uv_fs_req_cleanup(req)
    if result < 0 {
      error_cb(Errno::of_int(result.to_int()))
    } else {
      read_cb(result.to_int())
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
  return req
}

///|
extern "c" fn uv_fs_read_sync(
  uv : Loop,
  req : Fs,
  file : File,
  bufs_base : FixedArray[Bytes],
  bufs_offset : FixedArray[Int],
  bufs_length : FixedArray[Int],
  offset : Int64,
) -> Int = "moonbit_uv_fs_read_sync"

///|
pub fn Loop::fs_read_sync(
  self : Loop,
  file : File,
  bufs : Array[@bytes.View],
  offset~ : Int64 = -1,
) -> Int raise Errno {
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
  let status = uv_fs_read_sync(
    self, req, file, bufs_base, bufs_offset, bufs_length, offset,
  )
  if status < 0 {
    raise Errno::of_int(status)
  }
  status
}

///|
extern "c" fn uv_fs_write(
  uv : Loop,
  req : Fs,
  file : File,
  bufs_base : FixedArray[Bytes],
  bufs_offset : FixedArray[Int],
  bufs_length : FixedArray[Int],
  offset : Int64,
  write_cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_write"

///|
/// Asynchronously writes data from multiple buffers to a file.
///
/// This function initiates a write operation that will be handled asynchronously
/// by the event loop. The data is written from the provided array of byte views
/// to the file, which can be used for gather I/O operations. When the operation
/// completes, either the success callback or error callback will be invoked
/// depending on the result.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `file` : The file descriptor to write to, typically obtained from `fs_open`
/// or `fs_open_sync`.
/// * `bufs` : An array of byte views containing the data to write to the file.
/// The views define both the memory locations and the amount of data to write
/// from each buffer.
/// * `offset` : The file position to start writing to. If `-1` (default), writes
/// to the current file position. Otherwise, writes to the specified absolute
/// position in the file.
/// * `write_cb` : Success callback function that receives the filesystem request
/// handle and the number of bytes actually written when the operation succeeds.
/// * `error_cb` : Error callback function that receives the filesystem request
/// handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid file descriptor or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let path : Bytes = "test/fixtures/doc-test.txt"
/// let file = uv.fs_open_sync(
///   path,
///   @uv.OpenFlags::write_only(create=true),
///   0o644
/// )
/// let data : Bytes = "Hello, World!"
/// uv.fs_write(
///   file,
///   [data],
///   fn(written) { println("Wrote \{written} bytes") },
///   fn(error) { println("Error: \{error}") }
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.fs_close_sync(file)
/// uv.fs_unlink_sync(path)
/// uv.close()
/// ```
pub fn Loop::fs_write(
  self : Loop,
  file : File,
  bufs : Array[@bytes.View],
  offset~ : Int64 = -1,
  write_cb : (Int) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let result = req.result().to_int()
    uv_fs_req_cleanup(req)
    if result < 0 {
      error_cb(Errno::of_int(result))
    } else {
      write_cb(result)
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
  return req
}

///|
extern "c" fn uv_fs_write_sync(
  uv : Loop,
  req : Fs,
  file : File,
  bufs_base : FixedArray[Bytes],
  bufs_offset : FixedArray[Int],
  bufs_length : FixedArray[Int],
  offset : Int64,
) -> Int = "moonbit_uv_fs_write_sync"

///|
/// Synchronously writes data from multiple buffers to a file.
///
/// This function blocks the current thread until the write operation completes.
/// Unlike the asynchronous `fs_write` function, this operation does not require
/// callbacks and returns immediately upon successful completion or failure.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `file` : The file descriptor to write to, typically obtained from `fs_open`
/// or `fs_open_sync`.
/// * `bufs` : An array of byte views containing the data to write to the file.
/// The views define both the memory locations and the amount of data to write
/// from each buffer.
/// * `offset` : The file position to start writing to. If `-1` (default), writes
/// to the current file position. Otherwise, writes to the specified absolute
/// position in the file.
///
/// Throws an error of type `Errno` if the file cannot be written to (e.g.,
/// invalid file descriptor, insufficient permissions, disk full, or system
/// resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let path : Bytes = "test/fixtures/doc-test-sync.txt"
/// let file = uv.fs_open_sync(
///   path,
///   @uv.OpenFlags::write_only(create=true),
///   0o644
/// )
/// let data : Bytes = "Hello, World!"
/// uv.fs_write_sync(file, [data])
/// uv.fs_close_sync(file)
/// uv.fs_unlink_sync(path)
/// uv.close()
/// ```
pub fn Loop::fs_write_sync(
  self : Loop,
  file : File,
  bufs : Array[@bytes.View],
  offset~ : Int64 = -1,
) -> Unit raise Errno {
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
  let status = uv_fs_write_sync(
    self, req, file, bufs_base, bufs_offset, bufs_length, offset,
  )
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_ftruncate(
  uv : Loop,
  req : Fs,
  file : File,
  length : Int64,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_ftruncate"

///|
pub fn Loop::fs_ftruncate(
  self : Loop,
  file : File,
  length : Int64,
  k : () -> Unit,
  e : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      e(Errno::of_int(status))
    } else {
      k()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_ftruncate(self, req, file, length, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
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
  uv : Loop,
  req : Fs,
  path : Bytes,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_unlink"

///|
pub fn Loop::fs_unlink(
  self : Loop,
  path : Bytes,
  k : () -> Unit,
  e : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      e(Errno::of_int(status))
    } else {
      k()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_unlink(self, req, path, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_unlink_sync(uv : Loop, req : Fs, path : Bytes) -> Int = "moonbit_uv_fs_unlink_sync"

///|
pub fn Loop::fs_unlink_sync(self : Loop, path : Bytes) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_unlink_sync(self, req, path)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_mkdir(
  uv : Loop,
  req : Fs,
  path : Bytes,
  mode : Int,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_mkdir"

///|
/// Asynchronously creates a directory at the specified path with the given
/// permissions.
///
/// This function initiates a directory creation operation that will be handled
/// asynchronously by the event loop. When the operation completes, either the
/// success callback or error callback will be invoked depending on the result.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `path` : The directory path to create as a `Bytes` object. If you have a
///   `String`, `@string.View`, or `@bytes.View`, convert it to `Bytes` first
///   using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `mode` : The directory permissions to use when creating the directory
///   (octal notation, e.g., `0o755`).
/// * `mkdir_cb` : Success callback function that receives the filesystem request
///   handle when the directory is created successfully.
/// * `error_cb` : Error callback function that receives the filesystem request
///   handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid parameters or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let dir : Bytes = "test/fixtures/doc-test-dir"
/// uv.fs_mkdir(
///   dir,
///   0o755,
///   fn() { println("Directory created successfully") },
///   fn(error) {
///     println("Failed to create directory: \{error} (expected)")
///   }
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.fs_rmdir_sync(dir)
/// uv.close()
/// ```
pub fn Loop::fs_mkdir(
  self : Loop,
  path : Bytes,
  mode : Int,
  mkdir_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      mkdir_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_mkdir(self, req, path, mode, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_mkdir_sync(
  uv : Loop,
  req : Fs,
  path : Bytes,
  mode : Int,
) -> Int = "moonbit_uv_fs_mkdir_sync"

///|
/// Synchronously creates a directory at the specified path with the given
/// permissions.
///
/// This function blocks the current thread until the directory creation
/// operation completes. Unlike the asynchronous `fs_mkdir` function, this
/// operation does not require callbacks and returns immediately upon completion
/// or failure.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `path` : The directory path to create as a `Bytes` object. If you have a
/// `String`, `@string.View`, or `@bytes.View`, convert it to `Bytes` first
/// using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `mode` : The directory permissions to use when creating the directory
/// (octal notation, e.g., `0o755`).
///
/// Throws an error of type `Errno` if the directory cannot be created (e.g.,
/// path already exists, insufficient permissions, or invalid path).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// uv.fs_mkdir_sync("test/fixtures", 0o755) catch {
///   error => println("Failed to create directory: \{error} (expected)")
/// }
/// uv.close()
/// ```
pub fn Loop::fs_mkdir_sync(
  self : Loop,
  path : Bytes,
  mode : Int,
) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_mkdir_sync(self, req, path, mode)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_rmdir(
  uv : Loop,
  req : Fs,
  path : Bytes,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_rmdir"

///|
pub fn Loop::fs_rmdir(
  self : Loop,
  path : Bytes,
  rmdir_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      rmdir_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_rmdir(self, req, path, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_rmdir_sync(uv : Loop, req : Fs, path : Bytes) -> Int = "moonbit_uv_fs_rmdir_sync"

///|
pub fn Loop::fs_rmdir_sync(self : Loop, path : Bytes) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_rmdir_sync(self, req, path)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_scandir(
  uv : Loop,
  req : Fs,
  path : Bytes,
  flags : Int,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_scandir"

///|
struct Dirent {
  name : Bytes
  type_ : DirentType
}

///|
pub fn Dirent::name(self : Dirent) -> Bytes {
  self.name
}

///|
pub fn Dirent::type_(self : Dirent) -> DirentType {
  self.type_
}

///|
/// Type of directory entry, indicating the file system object kind.
pub enum DirentType {
  /// Unknown or unsupported file type
  Unknown
  /// Regular file
  File
  /// Directory
  Dir
  /// Symbolic link
  Link
  /// Named pipe (FIFO)
  Fifo
  /// Socket file
  Socket
  /// Character device
  Char
  /// Block device
  Block
}

///|
extern "c" fn uv_dirent_make(n : Int) -> @c.Pointer[Dirent] = "moonbit_uv_dirent_make"

///|
impl @c.Load for Dirent with load(pointer : @c.Pointer[Dirent], index : Int) -> Dirent {
  let name = uv_dirent_get_name(pointer, index)
  let buffer = @buffer.new()
  for i = 0; name[i] != 0; i = i + 1 {
    buffer.write_byte(name[i])
  }
  let name = buffer.contents()
  let type_ = uv_dirent_get_type(pointer, index)
  { name, type_ }
}

///|
extern "c" fn uv_dirent_get_name(
  dirent : @c.Pointer[Dirent],
  offset : Int,
) -> @c.Pointer[Byte] = "moonbit_uv_dirent_get_name"

///|
extern "c" fn uv_dirent_get_type(
  dirent : @c.Pointer[Dirent],
  offset : Int,
) -> DirentType = "moonbit_uv_dirent_get_type"

///|
extern "c" fn uv_dirent_delete(dirent : @c.Pointer[Dirent]) = "moonbit_uv_dirent_delete"

///|
extern "c" fn uv_fs_scandir_next(req : Fs, ent : @c.Pointer[Dirent]) -> Int = "moonbit_uv_fs_scandir_next"

///|
struct Scandir(Fs)

///|
pub fn Scandir::next(self : Scandir) -> Dirent raise Errno {
  let req = self.inner()
  let uv_dirent = uv_dirent_make(1)
  let status = uv_fs_scandir_next(req, uv_dirent)
  if status < 0 {
    uv_dirent_delete(uv_dirent)
    uv_fs_req_cleanup(req)
    raise Errno::of_int(status)
  }
  let dirent = uv_dirent[0]
  uv_dirent_delete(uv_dirent)
  dirent
}

///|
pub fn Loop::fs_scandir(
  self : Loop,
  path : Bytes,
  flags : Int,
  scandir_cb : (Scandir) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_scandir(self, req, path, flags, fn(req) {
    let status = uv_fs_get_result(req).to_int()
    if status < 0 {
      uv_fs_req_cleanup(req)
      error_cb(Errno::of_int(status))
    } else {
      scandir_cb(req)
    }
  })
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_scandir_sync(
  uv : Loop,
  req : Fs,
  path : Bytes,
  flags : Int,
) -> Int = "moonbit_uv_fs_scandir_sync"

///|
pub fn fs_scandir_sync(
  self : Loop,
  path : Bytes,
  flags : Int,
) -> Scandir raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_scandir_sync(self, req, path, flags)
  if status < 0 {
    uv_fs_req_cleanup(req)
    raise Errno::of_int(status)
  }
  req
}

///|
extern "c" fn uv_fs_rename(
  uv : Loop,
  req : Fs,
  path : Bytes,
  new_path : Bytes,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_rename"

///|
pub fn Loop::fs_rename(
  self : Loop,
  path : Bytes,
  new_path : Bytes,
  rename_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      rename_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_rename(self, req, path, new_path, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
struct CopyFileFlags(Int)

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
  copy_on_write~ : CopyOnWrite = False,
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
  uv : Loop,
  req : Fs,
  path : Bytes,
  new_path : Bytes,
  flags : Int,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_copyfile"

///|
pub fn Loop::fs_copyfile(
  self : Loop,
  path : Bytes,
  new_path : Bytes,
  flags : CopyFileFlags,
  copy_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      copy_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_copyfile(self, req, path, new_path, flags.inner(), cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_copyfile_sync(
  uv : Loop,
  req : Fs,
  path : Bytes,
  new_path : Bytes,
  flags : Int,
) -> Int = "moonbit_uv_fs_copyfile_sync"

///|
pub fn Loop::fs_copyfile_sync(
  self : Loop,
  path : Bytes,
  new_path : Bytes,
  flags : CopyFileFlags,
) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_copyfile_sync(self, req, path, new_path, flags.inner())
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_cwd(buffer : Bytes, length : FixedArray[Int]) -> Int = "moonbit_uv_cwd"

///|
pub fn cwd() -> Bytes raise Errno {
  let mut buffer = Bytes::make(64, 0)
  let length : FixedArray[Int] = [buffer.length()]
  let mut status = uv_cwd(buffer, length)
  if status == _ENOBUFS {
    buffer = Bytes::make(length[0], 0)
    status = uv_cwd(buffer, length)
  }
  if status < 0 {
    raise Errno::of_int(status)
  }
  return [..buffer[:length[0]]]
}

///|
extern "c" fn uv_fs_get_ptr(req : Fs) -> @c.Pointer[Unit] = "moonbit_uv_fs_get_ptr"

///|
extern "c" fn uv_fs_get_dir(req : Fs) -> Dir = "moonbit_uv_fs_get_dir"

///|
extern "c" fn uv_fs_realpath(
  uv : Loop,
  req : Fs,
  path : Bytes,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_realpath"

///|
struct Stat(Bytes)

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
pub fn Stat::is_regular(self : Stat) -> Bool {
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
pub fn Stat::is_socket(self : Stat) -> Bool raise Errno {
  if _S_IFSOCK == @uint64.max_value {
    raise ENOSYS
  }
  (self.mode() & _S_IFMT) == _S_IFSOCK
}

///|
#deprecated("Use Stat::is_fifo instead")
pub fn Stat::is_pipe(self : Stat) -> Bool {
  (self.mode() & _S_IFMT) == _S_IFIFO
}

///|
pub fn Stat::is_fifo(self : Stat) -> Bool {
  (self.mode() & _S_IFMT) == _S_IFIFO
}

///|
pub fn Stat::is_block_device(self : Stat) -> Bool raise Errno {
  if _S_IFBLK == @uint64.max_value {
    raise ENOSYS
  }
  (self.mode() & _S_IFMT) == _S_IFBLK
}

///|
pub fn Stat::is_character_device(self : Stat) -> Bool {
  (self.mode() & _S_IFMT) == _S_IFCHR
}

///|
pub fn Stat::type_(self : Stat) -> DirentType {
  let type_ = self.mode() & _S_IFMT
  if type_ == _S_IFREG {
    DirentType::File
  } else if type_ == _S_IFDIR {
    DirentType::Dir
  } else if type_ == _S_IFLNK {
    DirentType::Link
  } else if type_ == _S_IFSOCK {
    DirentType::Socket
  } else if type_ == _S_IFIFO {
    DirentType::Fifo
  } else if type_ == _S_IFCHR {
    DirentType::Char
  } else if type_ == _S_IFBLK {
    DirentType::Block
  } else {
    DirentType::Unknown
  }
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
  uv : Loop,
  req : Fs,
  path : Bytes,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_stat"

///|
pub fn Loop::fs_stat(
  self : Loop,
  path : Bytes,
  stat_cb : (Stat) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      uv_fs_req_cleanup(req)
      error_cb(Errno::of_int(status))
    } else {
      let statbuf = uv_fs_get_statbuf(req)
      uv_fs_req_cleanup(req)
      stat_cb(statbuf)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_stat(self, req, path, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_stat_sync(uv : Loop, req : Fs, path : Bytes) -> Int = "moonbit_uv_fs_stat_sync"

///|
pub fn Loop::fs_stat_sync(self : Loop, path : Bytes) -> Stat raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_stat_sync(self, req, path)
  if status < 0 {
    uv_fs_req_cleanup(req)
    raise Errno::of_int(status)
  }
  let stat = uv_fs_get_statbuf(req)
  uv_fs_req_cleanup(req)
  return stat
}

///|
extern "c" fn uv_fs_lstat(
  uv : Loop,
  req : Fs,
  path : Bytes,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_lstat"

///|
pub fn Loop::fs_lstat(
  self : Loop,
  path : Bytes,
  lstat_cb : (Stat) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      uv_fs_req_cleanup(req)
      error_cb(Errno::of_int(status))
    } else {
      let statbuf = uv_fs_get_statbuf(req)
      uv_fs_req_cleanup(req)
      lstat_cb(statbuf)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_lstat(self, req, path, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_fstat(
  uv : Loop,
  req : Fs,
  file : File,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_fstat"

///|
pub fn Loop::fs_fstat(
  self : Loop,
  file : File,
  fstat_cb : (Stat) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      uv_fs_req_cleanup(req)
      error_cb(Errno::of_int(status))
    } else {
      let statbuf = uv_fs_get_statbuf(req)
      uv_fs_req_cleanup(req)
      fstat_cb(statbuf)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_fstat(self, req, file, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
/// Asynchronously resolves a file path to its absolute canonical form.
///
/// This function initiates a path resolution operation that will be handled
/// asynchronously by the event loop. The resolved path eliminates symbolic
/// links, relative path components (like `.` and `..`), and redundant
/// separators to produce an absolute canonical path. When the operation
/// completes, either the success callback or error callback will be invoked
/// depending on the result.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `path` : The file path to resolve as a `Bytes` object. If you have a
///   `String`, `@string.View`, or `@bytes.View`, convert it to `Bytes` first
///   using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `path_cb` : Success callback function that receives the filesystem request
///   handle and the resolved absolute path when the operation succeeds.
/// * `error_cb` : Error callback function that receives the filesystem request
///   handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid parameters or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// uv.fs_realpath(
///   "test/fixtures/example.txt",
///   realpath => println("Resolved: \{realpath}"),
///   error => println("Failed to resolve path: \{error}")
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// ```
pub fn Loop::fs_realpath(
  self : Loop,
  path : Bytes,
  path_cb : (Bytes) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      uv_fs_req_cleanup(req)
      error_cb(Errno::of_int(status))
    } else {
      let ptr : @c.Pointer[Byte] = uv_fs_get_ptr(req).cast()
      let buffer = @buffer.new()
      for i = 0; ptr[i] != 0; i = i + 1 {
        buffer.write_byte(ptr[i])
      }
      let bytes = buffer.contents()
      uv_fs_req_cleanup(req)
      path_cb(bytes)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_realpath(self, req, path, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_realpath_sync(uv : Loop, req : Fs, path : Bytes) -> Int = "moonbit_uv_fs_realpath_sync"

///|
pub fn Loop::fs_realpath_sync(self : Loop, path : Bytes) -> Bytes raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_realpath_sync(self, req, path)
  if status < 0 {
    raise Errno::of_int(status)
  }
  let ptr : @c.Pointer[Byte] = uv_fs_get_ptr(req).cast()
  let buffer = @buffer.new()
  for i = 0; ptr[i] != 0; i = i + 1 {
    buffer.write_byte(ptr[i])
  }
  uv_fs_req_cleanup(req)
  buffer.contents()
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
struct AccessFlags(Int)

///|
pub fn AccessFlags::new(
  read~ : Bool = false,
  write~ : Bool = false,
  execute~ : Bool = false,
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
  uv : Loop,
  req : Fs,
  path : Bytes,
  mode : Int,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_access"

///|
pub fn Loop::fs_access(
  self : Loop,
  path : Bytes,
  mode : AccessFlags,
  access_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      access_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_access(self, req, path, mode.inner(), cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_access_sync(
  uv : Loop,
  req : Fs,
  path : Bytes,
  mode : Int,
) -> Int = "moonbit_uv_fs_access_sync"

///|
pub fn Loop::fs_access_sync(
  self : Loop,
  path : Bytes,
  mode : AccessFlags,
) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_access_sync(self, req, path, mode.inner())
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_get_path(req : Fs) -> Bytes = "moonbit_uv_fs_get_path"

///|
fn Fs::get_path(req : Fs) -> Bytes {
  uv_fs_get_path(req)
}

///|
extern "c" fn uv_fs_mkdtemp(
  uv : Loop,
  req : Fs,
  template : Bytes,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_mkdtemp"

///|
pub fn Loop::fs_mkdtemp(
  self : Loop,
  template : Bytes,
  mkdtemp_cb : (Bytes) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      uv_fs_req_cleanup(req)
      error_cb(Errno::of_int(status))
    } else {
      let path = req.get_path()
      uv_fs_req_cleanup(req)
      mkdtemp_cb(path)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_mkdtemp(self, req, template, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_mkdtemp_sync(uv : Loop, req : Fs, template : Bytes) -> Int = "moonbit_uv_fs_mkdtemp_sync"

///|
pub fn Loop::fs_mkdtemp_sync(
  self : Loop,
  template : Bytes,
) -> Bytes raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_mkdtemp_sync(self, req, template)
  if status < 0 {
    raise Errno::of_int(status)
  }
  let path = req.get_path()
  uv_fs_req_cleanup(req)
  return path
}

///|
extern "c" fn uv_fs_mkstemp(
  uv : Loop,
  req : Fs,
  template : Bytes,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_mkstemp"

///|
pub fn Loop::fs_mkstemp(
  self : Loop,
  template : Bytes,
  mkstemp_cb : (Bytes) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      let path = req.get_path()
      uv_fs_req_cleanup(req)
      mkstemp_cb(path)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_mkstemp(self, req, template, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_mkstemp_sync(uv : Loop, req : Fs, template : Bytes) -> Int = "moonbit_uv_fs_mkstemp_sync"

///|
pub fn Loop::fs_mkstemp_sync(
  self : Loop,
  template : Bytes,
) -> Bytes raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_mkstemp_sync(self, req, template)
  if status < 0 {
    uv_fs_req_cleanup(req)
    raise Errno::of_int(status)
  }
  let path = req.get_path()
  uv_fs_req_cleanup(req)
  path
}

///|
#external
type Dir

///|
extern "c" fn uv_dir_set(dir : Dir, entries : @c.Pointer[Dirent], n : Int) = "moonbit_uv_dir_set"

///|
extern "c" fn uv_fs_opendir(
  uv : Loop,
  req : Fs,
  path : Bytes,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_opendir"

///|
pub fn Loop::fs_opendir(
  self : Loop,
  path : Bytes,
  opendir_cb : (Dir) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      uv_fs_req_cleanup(req)
      error_cb(Errno::of_int(status))
    } else {
      let dir = uv_fs_get_dir(req)
      uv_fs_req_cleanup(req)
      opendir_cb(dir)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_opendir(self, req, path, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_readdir(
  uv : Loop,
  req : Fs,
  dir : Dir,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_readdir"

///|
pub fn Loop::fs_readdir(
  self : Loop,
  dir : Dir,
  n : Int,
  readdir_cb : (Array[Dirent]) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  let uv_dirents = uv_dirent_make(n)
  fn cb(req : Fs) {
    let status = req.result().to_int()
    if status < 0 {
      uv_fs_req_cleanup(req)
      uv_dir_set(dir, @c.null(), 0)
      uv_dirent_delete(uv_dirents)
      error_cb(Errno::of_int(status))
    } else {
      let dirents = []
      for i in 0..<status {
        dirents.push(uv_dirents[i])
      }
      uv_fs_req_cleanup(req)
      uv_dir_set(dir, @c.null(), 0)
      uv_dirent_delete(uv_dirents)
      readdir_cb(dirents)
    }
  }

  let req = uv_fs_make()
  uv_dir_set(dir, uv_dirents, n)
  let status = uv_fs_readdir(self, req, dir, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
extern "c" fn uv_fs_closedir(
  uv : Loop,
  req : Fs,
  dir : Dir,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_closedir"

///|
pub fn Loop::fs_closedir(
  self : Loop,
  dir : Dir,
  closedir_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      closedir_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_closedir(self, req, dir, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}
