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
#owned(req)
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
#owned(uv, req, path)
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
/// let errors = []
/// uv.fs_open(
///   "README.md",
///   OpenFlags::read_only(),
///   0o644,
///   file => uv.fs_close_sync(file) catch { _ => () },
///   (error) => errors.push(error),
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
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
#owned(uv, req, path)
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
#owned(uv, req)
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
/// let errors = []
/// let file = uv.fs_open_sync("README.md", OpenFlags::read_only(), 0o644)
/// uv.fs_close(
///   file,
///   () => println("File closed successfully"),
///   (error) => errors.push(error),
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
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
#owned(uv, req)
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
#owned(req)
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
#owned(uv, req)
extern "c" fn uv_fs_sendfile(
  uv : Loop,
  req : Fs,
  out_fd : File,
  in_fd : File,
  in_offset : Int64,
  length : UInt64,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_sendfile"

///|
/// Asynchronously transfers data between file descriptors.
///
/// This function initiates a sendfile operation that will be handled
/// asynchronously by the event loop. The sendfile operation is an efficient
/// way to transfer data from one file descriptor to another without copying
/// data through userspace. When the operation completes, either the success
/// callback or error callback will be invoked depending on the result.
///
/// On platforms that support it, this function uses the native sendfile()
/// system call for optimal performance. On platforms that don't support it,
/// it falls back to a read/write loop.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `out_fd` : The destination file descriptor to write to.
/// * `in_fd` : The source file descriptor to read from.
/// * `in_offset` : The offset in the input file to start reading from.
/// * `length` : The maximum number of bytes to transfer.
/// * `sendfile_cb` : Success callback function that receives the filesystem
///   request handle and the number of bytes transferred when the operation
///   succeeds.
/// * `error_cb` : Error callback function that receives the filesystem request
///   handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid file descriptors or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let errors = []
/// let dst_path : Bytes = "test/fixtures/example-sent.txt"
/// let src_file = uv.fs_open_sync("test/fixtures/example.txt", @uv.OpenFlags::read_only(), 0o644)
/// let dst_file = uv.fs_open_sync(dst_path, @uv.OpenFlags::write_only(create=true), 0o644)
/// uv.fs_sendfile(
///   dst_file,
///   src_file,
///   0L,
///   1024UL,
///   _ => {
///     try {
///       uv.fs_close_sync(src_file)
///       uv.fs_close_sync(dst_file)
///       uv.fs_unlink_sync(dst_path)
///     } catch { e => errors.push(e) }
///   },
///   error => {
///     errors.push(error)
///     try {
///       uv.fs_close_sync(src_file)
///       uv.fs_close_sync(dst_file)
///       uv.fs_unlink_sync(dst_path)
///     } catch { e => errors.push(e) }
///   }
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
/// ```
pub fn Loop::fs_sendfile(
  self : Loop,
  out_fd : File,
  in_fd : File,
  in_offset : Int64,
  length : UInt64,
  sendfile_cb : (Int64) -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let result = req.result()
    uv_fs_req_cleanup(req)
    if result < 0 {
      error_cb(Errno::of_int(result.to_int()))
    } else {
      sendfile_cb(result)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_sendfile(self, req, out_fd, in_fd, in_offset, length, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
#owned(uv, req)
extern "c" fn uv_fs_sendfile_sync(
  uv : Loop,
  req : Fs,
  out_fd : File,
  in_fd : File,
  in_offset : Int64,
  length : UInt64,
) -> Int = "moonbit_uv_fs_sendfile_sync"

///|
/// Synchronously transfers data between file descriptors.
///
/// This function blocks the current thread until the sendfile operation
/// completes. Unlike the asynchronous `fs_sendfile` function, this operation
/// does not require callbacks and returns the number of bytes transferred
/// immediately upon successful completion.
///
/// On platforms that support it, this function uses the native sendfile()
/// system call for optimal performance. On platforms that don't support it,
/// it falls back to a read/write loop.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `out_fd` : The destination file descriptor to write to.
/// * `in_fd` : The source file descriptor to read from.
/// * `in_offset` : The offset in the input file to start reading from.
/// * `length` : The maximum number of bytes to transfer.
///
/// Returns the number of bytes actually transferred.
///
/// Throws an error of type `Errno` if the transfer cannot be completed (e.g.,
/// invalid file descriptors, I/O error, or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let dst_path : Bytes = "test/fixtures/example-sent.txt"
/// let src_file = uv.fs_open_sync("test/fixtures/example.txt", @uv.OpenFlags::read_only(), 0o644)
/// let dst_file = uv.fs_open_sync(dst_path, @uv.OpenFlags::write_only(create=true), 0o644)
/// let _ = uv.fs_sendfile_sync(dst_file, src_file, 0L, 1024UL)
/// uv.fs_close_sync(src_file)
/// uv.fs_close_sync(dst_file)
/// uv.fs_unlink_sync(dst_path)
/// uv.close()
/// ```
pub fn Loop::fs_sendfile_sync(
  self : Loop,
  out_fd : File,
  in_fd : File,
  in_offset : Int64,
  length : UInt64,
) -> Int64 raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_sendfile_sync(self, req, out_fd, in_fd, in_offset, length)
  if status < 0 {
    raise Errno::of_int(status)
  }
  status.to_int64()
}

///|
#owned(uv, req, path)
extern "c" fn uv_fs_chmod(
  uv : Loop,
  req : Fs,
  path : Bytes,
  mode : Int,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_chmod"

///|
/// Asynchronously changes the permissions of a file.
///
/// This function initiates a file permission change operation that will be
/// handled asynchronously by the event loop. When the operation completes,
/// either the success callback or error callback will be invoked depending on
/// the result.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `path` : The file path whose permissions to change as a `Bytes` object.
///   If you have a `String`, `@string.View`, or `@bytes.View`, convert it to
///   `Bytes` first using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `mode` : The new file permissions (octal notation, e.g., `0o644` for
///   read/write for owner, read-only for group and others).
/// * `chmod_cb` : Success callback function that receives the filesystem
///   request handle when the permission change succeeds.
/// * `error_cb` : Error callback function that receives the filesystem request
///   handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid parameters or system resource exhaustion).
///
/// Note: On Windows, this function can only modify the write permission bit.
/// All other permission bits are ignored.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let errors = []
/// let path : Bytes = "test/fixtures/example-chmod.txt"
/// uv.fs_chmod(
///   path,
///   0o644,  // rw-r--r--
///   () => (),
///   error => errors.push(error)
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
/// ```
pub fn Loop::fs_chmod(
  self : Loop,
  path : Bytes,
  mode : Int,
  chmod_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      chmod_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_chmod(self, req, path, mode, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
#owned(uv, req, path)
extern "c" fn uv_fs_chmod_sync(
  uv : Loop,
  req : Fs,
  path : Bytes,
  mode : Int,
) -> Int = "moonbit_uv_fs_chmod_sync"

///|
/// Synchronously changes the permissions of a file.
///
/// This function blocks the current thread until the file permission change
/// operation completes. Unlike the asynchronous `fs_chmod` function, this
/// operation does not require callbacks and returns immediately upon
/// completion or failure.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `path` : The file path whose permissions to change as a `Bytes` object.
///   If you have a `String`, `@string.View`, or `@bytes.View`, convert it to
///   `Bytes` first using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `mode` : The new file permissions (octal notation, e.g., `0o644` for
///   read/write for owner, read-only for group and others).
///
/// Throws an error of type `Errno` if the permissions cannot be changed (e.g.,
/// file does not exist, insufficient permissions, or system resource
/// exhaustion).
///
/// Note: On Windows, this function can only modify the write permission bit.
/// All other permission bits are ignored.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let path : Bytes = "test/fixtures/example-chmod-sync.txt"
/// uv.fs_chmod_sync(path, 0o644)  // rw-r--r--
/// uv.close()
/// ```
pub fn Loop::fs_chmod_sync(
  self : Loop,
  path : Bytes,
  mode : Int,
) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_chmod_sync(self, req, path, mode)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(uv, req)
extern "c" fn uv_fs_fchmod(
  uv : Loop,
  req : Fs,
  file : File,
  mode : Int,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_fchmod"

///|
/// Asynchronously changes the permissions of a file by file descriptor.
///
/// This function initiates a file permission change operation using a file
/// descriptor that will be handled asynchronously by the event loop. When the
/// operation completes, either the success callback or error callback will be
/// invoked depending on the result.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `file` : The file descriptor whose permissions to change, typically
///   obtained from `fs_open` or `fs_open_sync`.
/// * `mode` : The new file permissions (octal notation, e.g., `0o644` for
///   read/write for owner, read-only for group and others).
/// * `fchmod_cb` : Success callback function that receives the filesystem
///   request handle when the permission change succeeds.
/// * `error_cb` : Error callback function that receives the filesystem request
///   handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid file descriptor or system resource exhaustion).
///
/// Note: On Windows, this function can only modify the write permission bit.
/// All other permission bits are ignored.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let errors = []
/// let path : Bytes = "test/fixtures/example-fchmod.txt"
/// let file = uv.fs_open_sync(path, @uv.OpenFlags::read_write(), 0o644)
/// uv.fs_fchmod(
///   file,
///   0o600,  // rw-------
///   () => {
///     try uv.fs_close_sync(file) catch { e => errors.push(e) }
///   },
///   error => {
///     errors.push(error)
///     try uv.fs_close_sync(file) catch { e => errors.push(e) }
///   }
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
/// ```
pub fn Loop::fs_fchmod(
  self : Loop,
  file : File,
  mode : Int,
  fchmod_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      fchmod_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_fchmod(self, req, file, mode, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
#owned(uv, req)
extern "c" fn uv_fs_fchmod_sync(
  uv : Loop,
  req : Fs,
  file : File,
  mode : Int,
) -> Int = "moonbit_uv_fs_fchmod_sync"

///|
/// Synchronously changes the permissions of a file by file descriptor.
///
/// This function blocks the current thread until the file permission change
/// operation completes. Unlike the asynchronous `fs_fchmod` function, this
/// operation does not require callbacks and returns immediately upon
/// completion or failure.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `file` : The file descriptor whose permissions to change, typically
///   obtained from `fs_open` or `fs_open_sync`.
/// * `mode` : The new file permissions (octal notation, e.g., `0o644` for
///   read/write for owner, read-only for group and others).
///
/// Throws an error of type `Errno` if the permissions cannot be changed (e.g.,
/// invalid file descriptor, insufficient permissions, or system resource
/// exhaustion).
///
/// Note: On Windows, this function can only modify the write permission bit.
/// All other permission bits are ignored.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let path : Bytes = "test/fixtures/example-fchmod-sync.txt"
/// let file = uv.fs_open_sync(path, @uv.OpenFlags::read_write(), 0o644)
/// uv.fs_fchmod_sync(file, 0o600)  // rw-------
/// uv.fs_close_sync(file)
/// uv.close()
/// ```
pub fn Loop::fs_fchmod_sync(
  self : Loop,
  file : File,
  mode : Int,
) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_fchmod_sync(self, req, file, mode)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(uv, req, bufs_base, bufs_offset, bufs_length)
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
/// let errors = []
/// uv.fs_read(
///   @uv.stdin(),
///   [Bytes::make(100, 0)],
///   count => println("Read \{count} bytes"),
///   error => errors.push(error),
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
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
#owned(uv, req, bufs_base, bufs_offset, bufs_length)
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
#owned(uv, req, bufs_base, bufs_offset, bufs_length)
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
/// let errors = []
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
///   written => println("Wrote \{written} bytes"),
///   error => errors.push(error),
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.fs_close_sync(file)
/// uv.fs_unlink_sync(path)
/// uv.close()
/// for error in errors {
///   raise error
/// }
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
#owned(uv, req, bufs_base, bufs_offset, bufs_length)
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
#owned(uv, req)
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
#owned(uv, req)
extern "c" fn uv_fs_fsync(
  uv : Loop,
  req : Fs,
  file : File,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_fsync"

///|
/// Asynchronously synchronizes a file's data and metadata with storage.
///
/// This function initiates a file sync operation that will be handled
/// asynchronously by the event loop. The sync operation ensures that all
/// in-memory data and metadata changes for the file are written to the
/// underlying storage device. When the operation completes, either the
/// success callback or error callback will be invoked depending on the result.
///
/// This is equivalent to the `fsync()` system call, which synchronizes both
/// the file's data and metadata (such as timestamps and file size).
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `file` : The file descriptor to synchronize, typically obtained from
///   `fs_open` or `fs_open_sync`.
/// * `sync_cb` : Success callback function that receives the filesystem request
///   handle when the sync operation completes successfully.
/// * `error_cb` : Error callback function that receives the filesystem request
///   handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid file descriptor or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let errors = []
/// let path : Bytes = "test/fixtures/sync-test.txt"
/// let file = uv.fs_open_sync(
///   path,
///   @uv.OpenFlags::write_only(create=true),
///   0o644
/// )
/// let data : Bytes = "Hello, World!"
/// uv.fs_write_sync(file, [data])
/// uv.fs_fsync(
///   file,
///   () => println("File synced successfully"),
///   error => errors.push(error),
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.fs_close_sync(file)
/// uv.fs_unlink_sync(path)
/// uv.close()
/// for error in errors {
///   raise error
/// }
/// ```
pub fn Loop::fs_fsync(
  self : Loop,
  file : File,
  sync_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let result = req.result()
    uv_fs_req_cleanup(req)
    if result < 0 {
      error_cb(Errno::of_int(result.to_int()))
    } else {
      sync_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_fsync(self, req, file, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
#owned(uv, req)
extern "c" fn uv_fs_fsync_sync(uv : Loop, req : Fs, file : File) -> Int = "moonbit_uv_fs_fsync_sync"

///|
/// Synchronously synchronizes a file's data and metadata with storage.
///
/// This function blocks the current thread until the file sync operation
/// completes. Unlike the asynchronous `fs_fsync` function, this operation does
/// not require callbacks and returns immediately upon successful completion or
/// failure.
///
/// This is equivalent to the `fsync()` system call, which synchronizes both
/// the file's data and metadata (such as timestamps and file size).
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `file` : The file descriptor to synchronize, typically obtained from
///   `fs_open` or `fs_open_sync`.
///
/// Throws an error of type `Errno` if the file cannot be synchronized (e.g.,
/// invalid file descriptor, I/O error, or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let path : Bytes = "test/fixtures/sync-test-sync.txt"
/// let file = uv.fs_open_sync(
///   path,
///   @uv.OpenFlags::write_only(create=true),
///   0o644
/// )
/// let data : Bytes = "Hello, World!"
/// uv.fs_write_sync(file, [data])
/// uv.fs_fsync_sync(file)
/// uv.fs_close_sync(file)
/// uv.fs_unlink_sync(path)
/// uv.close()
/// ```
pub fn Loop::fs_fsync_sync(self : Loop, file : File) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_fsync_sync(self, req, file)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(uv, req)
extern "c" fn uv_fs_fdatasync(
  uv : Loop,
  req : Fs,
  file : File,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_fdatasync"

///|
/// Asynchronously synchronizes a file's data with storage.
///
/// This function initiates a file data sync operation that will be handled
/// asynchronously by the event loop. The sync operation ensures that all
/// in-memory data changes for the file are written to the underlying storage
/// device, but does not necessarily synchronize metadata. When the operation
/// completes, either the success callback or error callback will be invoked
/// depending on the result.
///
/// This is equivalent to the `fdatasync()` system call, which synchronizes
/// only the file's data but not necessarily the metadata (such as timestamps).
/// This can be faster than `fs_fsync` since it doesn't need to wait for
/// metadata writes.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `file` : The file descriptor to synchronize, typically obtained from
///   `fs_open` or `fs_open_sync`.
/// * `sync_cb` : Success callback function that receives the filesystem request
///   handle when the data sync operation completes successfully.
/// * `error_cb` : Error callback function that receives the filesystem request
///   handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid file descriptor or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let errors = []
/// let path : Bytes = "test/fixtures/datasync-test.txt"
/// let file = uv.fs_open_sync(
///   path,
///   @uv.OpenFlags::write_only(create=true),
///   0o644
/// )
/// let data : Bytes = "Hello, World!"
/// uv.fs_write_sync(file, [data])
/// uv.fs_fdatasync(
///   file,
///   () => println("File data synced successfully"),
///   error => errors.push(error),
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.fs_close_sync(file)
/// uv.fs_unlink_sync(path)
/// uv.close()
/// for error in errors {
///   raise error
/// }
/// ```
pub fn Loop::fs_fdatasync(
  self : Loop,
  file : File,
  sync_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let result = req.result()
    uv_fs_req_cleanup(req)
    if result < 0 {
      error_cb(Errno::of_int(result.to_int()))
    } else {
      sync_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_fdatasync(self, req, file, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
#owned(uv, req)
extern "c" fn uv_fs_fdatasync_sync(uv : Loop, req : Fs, file : File) -> Int = "moonbit_uv_fs_fdatasync_sync"

///|
/// Synchronously synchronizes a file's data with storage.
///
/// This function blocks the current thread until the file data sync operation
/// completes. Unlike the asynchronous `fs_fdatasync` function, this operation
/// does not require callbacks and returns immediately upon successful
/// completion or failure.
///
/// This is equivalent to the `fdatasync()` system call, which synchronizes
/// only the file's data but not necessarily the metadata (such as timestamps).
/// This can be faster than `fs_fsync_sync` since it doesn't need to wait for
/// metadata writes.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `file` : The file descriptor to synchronize, typically obtained from
///   `fs_open` or `fs_open_sync`.
///
/// Throws an error of type `Errno` if the file data cannot be synchronized
/// (e.g., invalid file descriptor, I/O error, or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let path : Bytes = "test/fixtures/datasync-test-sync.txt"
/// let file = uv.fs_open_sync(
///   path,
///   @uv.OpenFlags::write_only(create=true),
///   0o644
/// )
/// let data : Bytes = "Hello, World!"
/// uv.fs_write_sync(file, [data])
/// uv.fs_fdatasync_sync(file)
/// uv.fs_close_sync(file)
/// uv.fs_unlink_sync(path)
/// uv.close()
/// ```
pub fn Loop::fs_fdatasync_sync(self : Loop, file : File) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_fdatasync_sync(self, req, file)
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
#owned(uv, req, path)
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
#owned(uv, req, path)
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
#owned(uv, req, path)
extern "c" fn uv_fs_chown(
  uv : Loop,
  req : Fs,
  path : Bytes,
  uid : Uid,
  gid : Gid,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_chown"

///|
/// Asynchronously changes the owner and group of a file.
///
/// This function initiates a file ownership change operation that will be
/// handled asynchronously by the event loop. When the operation completes,
/// either the success callback or error callback will be invoked depending on
/// the result.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `path` : The file path whose ownership to change as a `Bytes` object. If
///   you have a `String`, `@string.View`, or `@bytes.View`, convert it to
///   `Bytes` first using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `uid` : The new user ID (UID) for the file. Use `-1` (or `UInt::max_value`)
///   to leave the current owner unchanged.
/// * `gid` : The new group ID (GID) for the file. Use `-1` (or `UInt::max_value`)
///   to leave the current group unchanged.
/// * `chown_cb` : Success callback function that receives the filesystem request
///   handle when the ownership change succeeds.
/// * `error_cb` : Error callback function that receives the filesystem request
///   handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid parameters or system resource exhaustion).
///
/// Note: On Windows, this function is a no-op and always succeeds since Windows
/// doesn't use the same ownership model as Unix-like systems.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let errors = []
/// let path : Bytes = "test/fixtures/example.txt"
/// let passwd = @uv.os_get_passwd()
/// uv.fs_chown(
///   path,
///   passwd.uid(),
///   passwd.gid(),
///   () => println("Ownership changed successfully"),
///   error => errors.push(error)
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
/// ```
pub fn Loop::fs_chown(
  self : Loop,
  path : Bytes,
  uid : Uid,
  gid : Gid,
  chown_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      chown_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_chown(self, req, path, uid, gid, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
#owned(uv, req, path)
extern "c" fn uv_fs_chown_sync(
  uv : Loop,
  req : Fs,
  path : Bytes,
  uid : Uid,
  gid : Gid,
) -> Int = "moonbit_uv_fs_chown_sync"

///|
/// Synchronously changes the owner and group of a file.
///
/// This function blocks the current thread until the file ownership change
/// operation completes. Unlike the asynchronous `fs_chown` function, this
/// operation does not require callbacks and returns immediately upon
/// completion or failure.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `path` : The file path whose ownership to change as a `Bytes` object. If
///   you have a `String`, `@string.View`, or `@bytes.View`, convert it to
///   `Bytes` first using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `uid` : The new user ID (UID) for the file. Use `-1` (or `UInt::max_value`)
///   to leave the current owner unchanged.
/// * `gid` : The new group ID (GID) for the file. Use `-1` (or `UInt::max_value`)
///   to leave the current group unchanged.
///
/// Throws an error of type `Errno` if the ownership cannot be changed (e.g.,
/// file does not exist, insufficient permissions, or system resource
/// exhaustion).
///
/// Note: On Windows, this function is a no-op and always succeeds since Windows
/// doesn't use the same ownership model as Unix-like systems.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let path : Bytes = "test/fixtures/example.txt"
/// let passwd = @uv.os_get_passwd()
/// uv.fs_chown_sync(path, passwd.uid(), passwd.gid())
/// uv.close()
/// ```
pub fn Loop::fs_chown_sync(
  self : Loop,
  path : Bytes,
  uid : Uid,
  gid : Gid,
) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_chown_sync(self, req, path, uid, gid)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(uv, req)
extern "c" fn uv_fs_fchown(
  uv : Loop,
  req : Fs,
  file : File,
  uid : Uid,
  gid : Gid,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_fchown"

///|
/// Asynchronously changes the owner and group of a file by file descriptor.
///
/// This function initiates a file ownership change operation using a file
/// descriptor that will be handled asynchronously by the event loop. When the
/// operation completes, either the success callback or error callback will be
/// invoked depending on the result.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `file` : The file descriptor whose ownership to change, typically obtained
///   from `fs_open` or `fs_open_sync`.
/// * `uid` : The new user ID (UID) for the file. Use `-1` (or `UInt::max_value`)
///   to leave the current owner unchanged.
/// * `gid` : The new group ID (GID) for the file. Use `-1` (or `UInt::max_value`)
///   to leave the current group unchanged.
/// * `fchown_cb` : Success callback function that receives the filesystem
///   request handle when the ownership change succeeds.
/// * `error_cb` : Error callback function that receives the filesystem request
///   handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid file descriptor or system resource exhaustion).
///
/// Note: On Windows, this function is a no-op and always succeeds since Windows
/// doesn't use the same ownership model as Unix-like systems.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let errors = []
/// let path : Bytes = "test/fixtures/example.txt"
/// let passwd = @uv.os_get_passwd()
/// let file = uv.fs_open_sync(path, @uv.OpenFlags::read_write(), 0o644)
/// uv.fs_fchown(
///   file,
///   passwd.uid(),
///   passwd.gid(),
///   () => {
///     try uv.fs_close_sync(file) catch { e => errors.push(e) }
///   },
///   error => {
///     errors.push(error)
///     try uv.fs_close_sync(file) catch { e => errors.push(e) }
///   }
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
/// ```
pub fn Loop::fs_fchown(
  self : Loop,
  file : File,
  uid : Uid,
  gid : Gid,
  fchown_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      fchown_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_fchown(self, req, file, uid, gid, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
#owned(uv, req)
extern "c" fn uv_fs_fchown_sync(
  uv : Loop,
  req : Fs,
  file : File,
  uid : Uid,
  gid : Gid,
) -> Int = "moonbit_uv_fs_fchown_sync"

///|
/// Synchronously changes the owner and group of a file by file descriptor.
///
/// This function blocks the current thread until the file ownership change
/// operation completes. Unlike the asynchronous `fs_fchown` function, this
/// operation does not require callbacks and returns immediately upon
/// completion or failure.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `file` : The file descriptor whose ownership to change, typically obtained
///   from `fs_open` or `fs_open_sync`.
/// * `uid` : The new user ID (UID) for the file. Use `-1` (or `UInt::max_value`)
///   to leave the current owner unchanged.
/// * `gid` : The new group ID (GID) for the file. Use `-1` (or `UInt::max_value`)
///   to leave the current group unchanged.
///
/// Throws an error of type `Errno` if the ownership cannot be changed (e.g.,
/// invalid file descriptor, insufficient permissions, or system resource
/// exhaustion).
///
/// Note: On Windows, this function is a no-op and always succeeds since Windows
/// doesn't use the same ownership model as Unix-like systems.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let path : Bytes = "test/fixtures/example.txt"
/// let file = uv.fs_open_sync(path, @uv.OpenFlags::read_write(), 0o644)
/// let passwd = @uv.os_get_passwd()
/// // Change to user ID 1000 and group ID 1000
/// uv.fs_fchown_sync(file, passwd.uid(), passwd.gid())
/// uv.fs_close_sync(file)
/// uv.close()
/// ```
pub fn Loop::fs_fchown_sync(
  self : Loop,
  file : File,
  uid : Uid,
  gid : Gid,
) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_fchown_sync(self, req, file, uid, gid)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(uv, req, path)
extern "c" fn uv_fs_lchown(
  uv : Loop,
  req : Fs,
  path : Bytes,
  uid : Uid,
  gid : Gid,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_lchown"

///|
/// Asynchronously changes the owner and group of a symbolic link.
///
/// This function initiates a symbolic link ownership change operation that will
/// be handled asynchronously by the event loop. Unlike `fs_chown`, this
/// function changes the ownership of the symbolic link itself rather than the
/// file it points to. When the operation completes, either the success callback
/// or error callback will be invoked depending on the result.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `path` : The symbolic link path whose ownership to change as a `Bytes`
///   object. If you have a `String`, `@string.View`, or `@bytes.View`, convert
///   it to `Bytes` first using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `uid` : The new user ID (UID) for the symbolic link. Use `-1` (or 
///   `UInt::max_value`) to leave the current owner unchanged.
/// * `gid` : The new group ID (GID) for the symbolic link. Use `-1` (or
///   `UInt::max_value`) to leave the current group unchanged.
/// * `lchown_cb` : Success callback function that receives the filesystem
///   request handle when the ownership change succeeds.
/// * `error_cb` : Error callback function that receives the filesystem request
///   handle and the error code when the operation fails.
///
/// Throws an error of type `Errno` if the operation cannot be initiated (e.g.,
/// invalid parameters or system resource exhaustion).
///
/// Note: On Windows, this function is a no-op and always succeeds since Windows
/// doesn't use the same ownership model as Unix-like systems.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let errors = []
/// let target_file : Bytes = "test/fixtures/example.txt"
/// let symlink_file : Bytes = "test/fixtures/example-lchown.txt"
/// let passwd = @uv.os_get_passwd()
/// // First create a symlink
/// uv.fs_symlink_sync(target_file, symlink_file, @uv.SymlinkFlags::new())
/// uv.fs_lchown(
///   symlink_file,
///   passwd.uid(),
///   passwd.gid(),
///   () => {
///     try uv.fs_unlink_sync(symlink_file) catch { e => errors.push(e) }
///   },
///   error => {
///     errors.push(error)
///     try uv.fs_unlink_sync(symlink_file) catch { e => errors.push(e) }
///   }
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
/// ```
pub fn Loop::fs_lchown(
  self : Loop,
  path : Bytes,
  uid : Uid,
  gid : Gid,
  lchown_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      lchown_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_lchown(self, req, path, uid, gid, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
#owned(uv, req, path)
extern "c" fn uv_fs_lchown_sync(
  uv : Loop,
  req : Fs,
  path : Bytes,
  uid : Uid,
  gid : Gid,
) -> Int = "moonbit_uv_fs_lchown_sync"

///|
/// Synchronously changes the owner and group of a symbolic link.
///
/// This function blocks the current thread until the symbolic link ownership
/// change operation completes. Unlike the asynchronous `fs_lchown` function,
/// this operation does not require callbacks and returns immediately upon
/// completion or failure. Unlike `fs_chown_sync`, this function changes the
/// ownership of the symbolic link itself rather than the file it points to.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `path` : The symbolic link path whose ownership to change as a `Bytes`
///   object. If you have a `String`, `@string.View`, or `@bytes.View`, convert
///   it to `Bytes` first using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `uid` : The new user ID (UID) for the symbolic link. Use `-1` (or
///   `UInt::max_value`) to leave the current owner unchanged.
/// * `gid` : The new group ID (GID) for the symbolic link. Use `-1` (or
///   `UInt::max_value`) to leave the current group unchanged.
///
/// Throws an error of type `Errno` if the ownership cannot be changed (e.g.,
/// symbolic link does not exist, insufficient permissions, or system resource
/// exhaustion).
///
/// Note: On Windows, this function is a no-op and always succeeds since Windows
/// doesn't use the same ownership model as Unix-like systems.
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let target_file : Bytes = "test/fixtures/example.txt"
/// let symlink_file : Bytes = "test/fixtures/example-lchown-sync.txt"
/// let passwd = @uv.os_get_passwd()
/// uv.fs_symlink_sync(target_file, symlink_file, @uv.SymlinkFlags::new())
/// uv.fs_lchown_sync(symlink_file, passwd.uid(), passwd.gid())
/// uv.fs_unlink_sync(symlink_file)
/// uv.close()
/// ```
pub fn Loop::fs_lchown_sync(
  self : Loop,
  path : Bytes,
  uid : Uid,
  gid : Gid,
) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_lchown_sync(self, req, path, uid, gid)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(uv, req, path)
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
/// let es = []
/// let dir : Bytes = "test/fixtures/doc-test-dir"
/// uv.fs_mkdir(
///   dir,
///   0o755,
///   () => println("Directory created successfully"),
///   (e) => es.push(e)
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.fs_rmdir_sync(dir)
/// uv.close()
/// for e in es {
///   raise e
/// }
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
#owned(uv, req, path)
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
/// try {
///   uv.fs_mkdir_sync("test/fixtures", 0o755)
///   fail("Directory should not exist")
/// } catch {
///   Errno::EEXIST => ()
///   error => raise error
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
#owned(uv, req, path)
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
#owned(uv, req, path)
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
#owned(uv, req, path)
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
#owned(req)
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
#owned(uv, req, path)
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
#owned(uv, req, path, new_path)
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
#owned(uv, req, path, new_path)
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
#owned(uv, req, path, new_path)
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
#owned(buffer, length)
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
#owned(req)
extern "c" fn uv_fs_get_ptr(req : Fs) -> @c.Pointer[Unit] = "moonbit_uv_fs_get_ptr"

///|
#owned(req)
extern "c" fn uv_fs_get_dir(req : Fs) -> Dir = "moonbit_uv_fs_get_dir"

///|
#owned(uv, req, path)
extern "c" fn uv_fs_realpath(
  uv : Loop,
  req : Fs,
  path : Bytes,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_realpath"

///|
struct Stat(Bytes)

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_dev(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_dev"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_mode(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_mode"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_nlink(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_nlink"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_uid(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_uid"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_gid(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_gid"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_rdev(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_rdev"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_ino(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_ino"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_size(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_size"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_blksize(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_blksize"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_blocks(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_blocks"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_flags(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_flags"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_gen(stat : Stat) -> UInt64 = "moonbit_uv_stat_get_gen"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_atim_sec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_atim_sec"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_atim_nsec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_atim_nsec"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_mtim_sec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_mtim_sec"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_mtim_nsec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_mtim_nsec"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_ctim_sec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_ctim_sec"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_ctim_nsec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_ctim_nsec"

///|
#owned(stat)
extern "c" fn moonbit_uv_stat_get_birthtim_sec(stat : Stat) -> Int64 = "moonbit_uv_stat_get_birthtim_sec"

///|
#owned(stat)
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
#owned(req)
extern "c" fn uv_fs_get_statbuf(req : Fs) -> Stat = "moonbit_uv_fs_get_statbuf"

///|
#owned(uv, req, path)
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
#owned(uv, req, path)
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
#owned(uv, req, path)
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
#owned(uv, req)
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
/// let errors = []
/// uv.fs_realpath(
///   "test/fixtures/example.txt",
///   realpath => println("Resolved: \{realpath}"),
///   error => errors.push(error)
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
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
#owned(uv, req, path)
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
#owned(uv, req, path)
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
#owned(uv, req, path)
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
#owned(req)
extern "c" fn uv_fs_get_path(req : Fs) -> Bytes = "moonbit_uv_fs_get_path"

///|
fn Fs::get_path(req : Fs) -> Bytes {
  uv_fs_get_path(req)
}

///|
#owned(uv, req, template)
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
#owned(uv, req, template)
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
#owned(uv, req, template)
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
#owned(uv, req, template)
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
#owned(uv, req, path)
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
#owned(uv, req, dir)
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
      uv_dir_set(dir, @c.Pointer::null(), 0)
      uv_dirent_delete(uv_dirents)
      error_cb(Errno::of_int(status))
    } else {
      let dirents = []
      for i in 0..<status {
        dirents.push(uv_dirents[i])
      }
      uv_fs_req_cleanup(req)
      uv_dir_set(dir, @c.Pointer::null(), 0)
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
#owned(uv, req, dir)
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

///|
#owned(uv, req, path, new_path)
extern "c" fn uv_fs_link(
  uv : Loop,
  req : Fs,
  path : Bytes,
  new_path : Bytes,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_link"

///|
/// Asynchronously creates a hard link from `new_path` to `path`.
///
/// This function initiates a hard link creation operation that will be handled
/// asynchronously by the event loop. A hard link creates an additional directory
/// entry that points to the same file data as the original path. When the
/// operation completes, either the success callback or error callback will be
/// invoked depending on the result.
///
/// Hard links can only be created for files (not directories) and both paths
/// must be on the same filesystem. Unlike symbolic links, hard links point
/// directly to the file data and remain valid even if the original path is
/// removed.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `path` : The existing file path to link to as a `Bytes` object. If you have
///   a `String`, `@string.View`, or `@bytes.View`, convert it to `Bytes` first
///   using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `new_path` : The new path for the hard link as a `Bytes` object.
/// * `link_cb` : Success callback function that receives the filesystem request
///   handle when the hard link is created successfully.
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
/// let errors = []
/// let original_file : Bytes = "test/fixtures/example.txt"
/// let link_file : Bytes = "test/fixtures/example-link.txt"
/// uv.fs_link(
///   original_file,
///   link_file,
///   () => {
///     println("Hard link created successfully")
///     try uv.fs_unlink_sync(link_file) catch { e => errors.push(e) }
///   },
///   error => errors.push(error)
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
/// ```
pub fn Loop::fs_link(
  self : Loop,
  path : Bytes,
  new_path : Bytes,
  link_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      link_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_link(self, req, path, new_path, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
#owned(uv, req, path, new_path)
extern "c" fn uv_fs_link_sync(
  uv : Loop,
  req : Fs,
  path : Bytes,
  new_path : Bytes,
) -> Int = "moonbit_uv_fs_link_sync"

///|
/// Synchronously creates a hard link from `new_path` to `path`.
///
/// This function blocks the current thread until the hard link creation
/// operation completes. Unlike the asynchronous `fs_link` function, this
/// operation does not require callbacks and returns immediately upon
/// completion or failure.
///
/// Hard links can only be created for files (not directories) and both paths
/// must be on the same filesystem. Unlike symbolic links, hard links point
/// directly to the file data and remain valid even if the original path is
/// removed.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `path` : The existing file path to link to as a `Bytes` object. If you have
///   a `String`, `@string.View`, or `@bytes.View`, convert it to `Bytes` first
///   using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `new_path` : The new path for the hard link as a `Bytes` object.
///
/// Throws an error of type `Errno` if the hard link cannot be created (e.g.,
/// file does not exist, paths on different filesystems, insufficient
/// permissions, or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let original_file : Bytes = "test/fixtures/example.txt"
/// let link_file : Bytes = "test/fixtures/example-link-sync.txt"
/// uv.fs_link_sync(original_file, link_file)
/// // Verify the link exists
/// let stat = uv.fs_stat_sync(link_file)
/// @assert.t(stat.is_file())
/// // Clean up
/// uv.fs_unlink_sync(link_file)
/// uv.close()
/// ```
pub fn Loop::fs_link_sync(
  self : Loop,
  path : Bytes,
  new_path : Bytes,
) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_link_sync(self, req, path, new_path)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_UV_FS_SYMLINK_DIR() -> Int = "moonbit_uv_fs_UV_FS_SYMLINK_DIR"

///|
let _UV_FS_SYMLINK_DIR : Int = uv_fs_UV_FS_SYMLINK_DIR()

///|
extern "c" fn uv_fs_UV_FS_SYMLINK_JUNCTION() -> Int = "moonbit_uv_fs_UV_FS_SYMLINK_JUNCTION"

///|
let _UV_FS_SYMLINK_JUNCTION : Int = uv_fs_UV_FS_SYMLINK_JUNCTION()

///|
struct SymlinkFlags(Int)

///|
/// Creates symbolic link flags for different types of symbolic links.
///
/// Parameters:
///
/// * `dir` : Whether the symlink points to a directory (Windows only). When
///   `true`, creates a directory symlink on Windows. This flag is ignored on
///   Unix-like systems where symlink type is determined automatically.
///   Defaults to `false`.
/// * `junction` : Whether to create a junction point (Windows only). When
///   `true`, creates a junction point instead of a regular symlink on Windows.
///   Junction points have different permissions and behavior than regular
///   symlinks. This flag is ignored on Unix-like systems. Defaults to `false`.
///
/// Returns a `SymlinkFlags` instance configured with the specified behaviors.
///
/// Example:
///
/// ```moonbit
/// // Regular file symlink (works on all platforms)
/// ignore(@uv.SymlinkFlags::new())
///
/// // Directory symlink (needed on Windows for directories)
/// ignore(@uv.SymlinkFlags::new(dir=true))
///
/// // Junction point (Windows-specific)
/// ignore(@uv.SymlinkFlags::new(junction=true))
/// ```
pub fn SymlinkFlags::new(
  dir~ : Bool = false,
  junction~ : Bool = false,
) -> SymlinkFlags {
  let mut flags = 0
  if dir {
    flags = flags | _UV_FS_SYMLINK_DIR
  }
  if junction {
    flags = flags | _UV_FS_SYMLINK_JUNCTION
  }
  flags
}

///|
#owned(uv, req, path, new_path)
extern "c" fn uv_fs_symlink(
  uv : Loop,
  req : Fs,
  path : Bytes,
  new_path : Bytes,
  flags : Int,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_symlink"

///|
/// Asynchronously creates a symbolic link from `new_path` to `path`.
///
/// This function initiates a symbolic link creation operation that will be
/// handled asynchronously by the event loop. A symbolic link creates a file
/// that points to another file or directory by name. When the operation
/// completes, either the success callback or error callback will be invoked
/// depending on the result.
///
/// Unlike hard links, symbolic links can point to files or directories on
/// different filesystems and can point to non-existent targets. If the target
/// file is moved or deleted, the symlink becomes broken.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `path` : The target path that the symlink will point to as a `Bytes`
///   object. If you have a `String`, `@string.View`, or `@bytes.View`, convert
///   it to `Bytes` first using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `new_path` : The path where the symbolic link will be created as a `Bytes`
///   object.
/// * `flags` : Symbolic link creation flags. Use `SymlinkFlags::new()` with
///   optional parameters to specify symlink behavior on Windows.
/// * `symlink_cb` : Success callback function that receives the filesystem
///   request handle when the symbolic link is created successfully.
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
/// let errors = []
/// let target_file : Bytes = "test/fixtures/example.txt"
/// let symlink_file : Bytes = "test/fixtures/example-symlink.txt"
/// uv.fs_symlink(
///   target_file,
///   symlink_file,
///   @uv.SymlinkFlags::new(),
///   () => {
///     println("Symbolic link created successfully")
///     try uv.fs_unlink_sync(symlink_file) catch { e => errors.push(e) }
///   },
///   error => errors.push(error)
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
/// ```
pub fn Loop::fs_symlink(
  self : Loop,
  path : Bytes,
  new_path : Bytes,
  flags : SymlinkFlags,
  symlink_cb : () -> Unit,
  error_cb : (Errno) -> Unit,
) -> Fs raise Errno {
  fn cb(req : Fs) {
    let status = req.result().to_int()
    uv_fs_req_cleanup(req)
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      symlink_cb()
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_symlink(self, req, path, new_path, flags.inner(), cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
#owned(uv, req, path, new_path)
extern "c" fn uv_fs_symlink_sync(
  uv : Loop,
  req : Fs,
  path : Bytes,
  new_path : Bytes,
  flags : Int,
) -> Int = "moonbit_uv_fs_symlink_sync"

///|
/// Synchronously creates a symbolic link from `new_path` to `path`.
///
/// This function blocks the current thread until the symbolic link creation
/// operation completes. Unlike the asynchronous `fs_symlink` function, this
/// operation does not require callbacks and returns immediately upon
/// completion or failure.
///
/// Unlike hard links, symbolic links can point to files or directories on
/// different filesystems and can point to non-existent targets. If the target
/// file is moved or deleted, the symlink becomes broken.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `path` : The target path that the symlink will point to as a `Bytes`
///   object. If you have a `String`, `@string.View`, or `@bytes.View`, convert
///   it to `Bytes` first using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `new_path` : The path where the symbolic link will be created as a `Bytes`
///   object.
/// * `flags` : Symbolic link creation flags. Use `SymlinkFlags::new()` with
///   optional parameters to specify symlink behavior on Windows.
///
/// Throws an error of type `Errno` if the symbolic link cannot be created (e.g.,
/// insufficient permissions, invalid path, or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let target_file : Bytes = "test/fixtures/example.txt"
/// let symlink_file : Bytes = "test/fixtures/example-symlink-sync.txt"
/// uv.fs_symlink_sync(target_file, symlink_file, @uv.SymlinkFlags::new())
/// // Verify the symlink exists
/// let stat = uv.fs_lstat_sync(symlink_file)
/// @assert.t(stat.is_symlink())
/// // Clean up
/// uv.fs_unlink_sync(symlink_file)
/// uv.close()
/// ```
pub fn Loop::fs_symlink_sync(
  self : Loop,
  path : Bytes,
  new_path : Bytes,
  flags : SymlinkFlags,
) -> Unit raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_symlink_sync(self, req, path, new_path, flags.inner())
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
#owned(uv, req, path)
extern "c" fn uv_fs_readlink(
  uv : Loop,
  req : Fs,
  path : Bytes,
  cb : (Fs) -> Unit,
) -> Int = "moonbit_uv_fs_readlink"

///|
/// Asynchronously reads the target of a symbolic link.
///
/// This function initiates a symbolic link read operation that will be handled
/// asynchronously by the event loop. The operation reads the target path that
/// a symbolic link points to. When the operation completes, either the success
/// callback or error callback will be invoked depending on the result.
///
/// Parameters:
///
/// * `self` : The event loop instance to schedule the operation on.
/// * `path` : The symbolic link path to read as a `Bytes` object. If you have a
///   `String`, `@string.View`, or `@bytes.View`, convert it to `Bytes` first
///   using `@encoding.encode(encoding=UTF8, string_value)`.
/// * `readlink_cb` : Success callback function that receives the filesystem
///   request handle and the target path when the operation succeeds.
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
/// let errors = []
/// let target_file : Bytes = "test/fixtures/example.txt"
/// let symlink_file : Bytes = "test/fixtures/example-symlink.txt"
/// // First create a symlink
/// uv.fs_symlink_sync(target_file, symlink_file, @uv.SymlinkFlags::new())
/// // Then read its target
/// uv.fs_readlink(
///   symlink_file,
///   target => {
///     println("Symlink points to: \{target}")
///     try {
///       @assert.eq(target, target_file)
///       uv.fs_unlink_sync(symlink_file)
///     } catch { e => errors.push(e) }
///   },
///   error => errors.push(error)
/// )
/// |> ignore()
/// uv.run(Default)
/// uv.close()
/// for error in errors {
///   raise error
/// }
/// ```
pub fn Loop::fs_readlink(
  self : Loop,
  path : Bytes,
  readlink_cb : (Bytes) -> Unit,
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
      readlink_cb(bytes)
    }
  }

  let req = uv_fs_make()
  let status = uv_fs_readlink(self, req, path, cb)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return req
}

///|
#owned(uv, req, path)
extern "c" fn uv_fs_readlink_sync(uv : Loop, req : Fs, path : Bytes) -> Int = "moonbit_uv_fs_readlink_sync"

///|
/// Synchronously reads the target of a symbolic link.
///
/// This function blocks the current thread until the symbolic link read
/// operation completes. Unlike the asynchronous `fs_readlink` function, this
/// operation does not require callbacks and returns the target path immediately
/// upon successful completion.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `path` : The symbolic link path to read as a `Bytes` object. If you have a
///   `String`, `@string.View`, or `@bytes.View`, convert it to `Bytes` first
///   using `@encoding.encode(encoding=UTF8, string_value)`.
///
/// Returns the target path that the symbolic link points to as a `Bytes` object.
///
/// Throws an error of type `Errno` if the symbolic link cannot be read (e.g.,
/// path does not exist, path is not a symbolic link, insufficient permissions,
/// or system resource exhaustion).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let target_file : Bytes = "test/fixtures/example.txt"
/// let symlink_file : Bytes = "test/fixtures/example-symlink-sync.txt"
/// // First create a symlink
/// uv.fs_symlink_sync(target_file, symlink_file, @uv.SymlinkFlags::new())
/// // Then read its target
/// let target = uv.fs_readlink_sync(symlink_file)
/// @assert.eq(target, target_file)
/// // Clean up
/// uv.fs_unlink_sync(symlink_file)
/// uv.close()
/// ```
pub fn Loop::fs_readlink_sync(self : Loop, path : Bytes) -> Bytes raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_readlink_sync(self, req, path)
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
#owned(uv, req, path)
extern "c" fn uv_fs_lstat_sync(uv : Loop, req : Fs, path : Bytes) -> Int = "moonbit_uv_fs_lstat_sync"

///|
/// Synchronously gets file status information for a symbolic link.
///
/// This function blocks the current thread until the lstat operation completes.
/// Unlike `fs_stat_sync`, this function does not follow symbolic links and
/// returns information about the link itself rather than the target.
///
/// Parameters:
///
/// * `self` : The event loop instance to perform the operation on.
/// * `path` : The file or symbolic link path to examine as a `Bytes` object.
///
/// Returns a `Stat` structure containing file information.
///
/// Throws an error of type `Errno` if the file information cannot be obtained
/// (e.g., file does not exist, insufficient permissions, or I/O error).
///
/// Example:
///
/// ```moonbit
/// let uv = @uv.Loop::new()
/// let target_file : Bytes = "test/fixtures/example.txt"
/// let symlink_file : Bytes = "test/fixtures/example-lstat.txt"
/// uv.fs_symlink_sync(target_file, symlink_file, @uv.SymlinkFlags::new())
/// let stat = uv.fs_lstat_sync(symlink_file)
/// @assert.t(stat.is_symlink())
/// uv.fs_unlink_sync(symlink_file)
/// uv.close()
/// ```
pub fn Loop::fs_lstat_sync(self : Loop, path : Bytes) -> Stat raise Errno {
  let req = uv_fs_make()
  let status = uv_fs_lstat_sync(self, req, path)
  if status < 0 {
    uv_fs_req_cleanup(req)
    raise Errno::of_int(status)
  }
  let stat = uv_fs_get_statbuf(req)
  uv_fs_req_cleanup(req)
  return stat
}
