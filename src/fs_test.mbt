///|
fn[E : Error] raise_option(option : E?) -> Unit raise E {
  if option is Some(error) {
    raise error
  }
}

///|
fn test_close(uv : @uv.Loop, file : @uv.File, error : Ref[Errno?]) -> Unit {
  uv.fs_close(file, () => (), e => error.val = Some(e)) catch {
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
  error : Ref[Errno?]
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
  error : Ref[Errno?]
) -> Unit {
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
  ) catch {
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
  inspect(
    @encoding.decode(buffer.contents(), encoding=UTF8),
    content=
      #|Hello, world!
      #|
    ,
  )
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
  for nread = uv.fs_read_sync(file, [bytes])
      nread > 0
      nread = uv.fs_read_sync(file, [bytes]) {
    buffer.write_bytesview(bytes[:nread])
  }
  inspect(
    @encoding.decode(buffer.contents(), encoding=UTF8),
    content=
      #|Hello, world!
      #|
    ,
  )
  uv.close()
}

///|
test "mkdir" {
  let uv = @uv.Loop::new()
  let mut mkdir_error = None
  let mut rmdir_error = None
  uv.fs_mkdir(
    "test-dir",
    0,
    fn() {
      uv.fs_rmdir("test-dir", () => (), error => rmdir_error = Some(error)) catch {
        error => rmdir_error = Some(error)
      }
    },
    error => mkdir_error = Some(error),
  )
  uv.run(Default)
  uv.stop()
  uv.close()
  raise_option(mkdir_error)
  raise_option(rmdir_error)
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
          if not(e is Errno(EOF)) {
            error = Some(e)
          }
          break
        }
      }
      entries.push(dirent)
    },
    e => if not(e is Errno(EOF)) { error = Some(e) },
  )
  uv.run(Default)
  uv.stop()
  uv.close()
  @json.inspect(entries, content=[
    { "name": ".gitattributes", "type": "file" },
    { "name": "example.txt", "type": "file" },
  ])
  raise_option(error)
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
      uv.fs_unlink("test/fixtures/example-copy.txt", fn() {  }, fn(e) {
        error = Some(e)
      }) catch {
        e => error = Some(e)
      }
    },
    e => error = Some(e),
  )
  uv.run(Default)
  uv.stop()
  uv.close()
  raise_option(error)
}

///|
test "realpath" {
  let uv = @uv.Loop::new()
  let cwd = @uv.cwd()
  let errors : Array[Error] = []
  let file = "test/fixtures/example.txt"
  uv.fs_realpath(
    file,
    p => assert_true(p.has_prefix(cwd)) catch { e => errors.push(e) },
    e => errors.push(e),
  )
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
      assert_true(stat.is_file())
      assert_true(not(stat.is_directory()))
      @json.inspect(stat.size(), content="14")
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
  assert_true(stat.is_file())
  assert_false(stat.is_directory())
}

///|
test "lstat" {
  let uv = @uv.Loop::new()
  let errors : Array[Error] = []
  uv.fs_lstat(
    "test/fixtures",
    stat => try {
      // It should be a directory
      assert_true(stat.is_directory())
      // It shouldn't be a regular file
      assert_true(not(stat.is_file()))
    } catch {
      e => errors.push(e)
    },
    e => errors.push(e),
  )
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
        assert_true(stat.is_file())
        // It shouldn't be a directory
        assert_true(not(stat.is_directory()))
        // Size should be greater than 0
        assert_true(stat.size() > 0)
      } catch {
        e => errors.push(e)
      },
      e => errors.push(e),
    )
    uv.run(Default)
    uv.fs_close(fh, () => (), e => errors.push(e))
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
  let template = "test-dir-XXXXXX"
  uv.fs_mkdtemp(
    template,
    path => try {
      assert_true(path.has_prefix("test-dir-"))
      let stat = uv.fs_stat_sync(path)
      assert_true(stat.is_directory())
      uv.fs_rmdir_sync(path)
    } catch {
      e => error = Some(e)
    },
    e => error = Some(e),
  )
  uv.run(Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
}

///|
test "fs_mkdtemp_sync" {
  let uv = @uv.Loop::new()
  let template = "test-dir-XXXXXX"
  let path = uv.fs_mkdtemp_sync(template)
  assert_true(path.has_prefix("test-dir-"))
  let stat = uv.fs_stat_sync(path)
  assert_true(stat.is_directory())
  uv.fs_rmdir_sync(path)
  uv.close()
}

///|
test "fs_mkstemp" {
  let uv = @uv.Loop::new()
  let mut error : Error? = None
  let template = "test-file-XXXXXX"
  uv.fs_mkstemp(
    template,
    path => try {
      assert_true(path.has_prefix("test-file-"))
      let stat = uv.fs_stat_sync(path)
      assert_true(stat.is_file())
      uv.fs_unlink_sync(path)
    } catch {
      e => error = Some(e)
    },
    e => error = Some(e),
  )
  uv.run(Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
}

///|
test "fs_mkstemp_sync" {
  let uv = @uv.Loop::new()
  let template = "test-file-XXXXXX"
  let path = uv.fs_mkstemp_sync(template)
  assert_true(path.has_prefix("test-file-"))
  let stat = uv.fs_stat_sync(path)
  assert_true(stat.is_file())
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
      uv.fs_closedir(dir, () => (), error_cb) catch {
        e => error = Some(e)
      }
      return
    }
    for dirent in dirents {
      guard dirent.type_ is File else { continue }
      let name = dirent.name
      guard name.has_suffix(".mbt") else { continue }
      sources.push(name)
    }
    uv.fs_readdir(dir, 1, read_cb(dir, _), error_cb) catch {
      e => error = Some(e)
    }
  }

  fn open_cb(dir) {
    uv.fs_readdir(dir, 1, read_cb(dir, _), error_cb) catch {
      e => error = Some(e)
    }
  }

  uv.fs_opendir("src", open_cb, error_cb) catch {
    e => error = Some(e)
  }
  uv.run(Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
  sources.sort()
  @json.inspect(sources, content=[
    "fs.mbt", "ip.mbt", "os.mbt", "dns.mbt", "env.mbt", "req.mbt", "tcp.mbt", "tty.mbt",
    "udp.mbt", "args.mbt", "idle.mbt", "loop.mbt", "pipe.mbt", "time.mbt", "work.mbt",
    "debug.mbt", "error.mbt", "mutex.mbt", "timer.mbt", "handle.mbt", "random.mbt",
    "signal.mbt", "socket.mbt", "stream.mbt", "thread.mbt", "fs_test.mbt", "ip_test.mbt",
    "os_test.mbt", "process.mbt", "dns_test.mbt", "env_test.mbt", "fs_event.mbt",
    "tcp_test.mbt", "udp_test.mbt", "args_test.mbt", "idle_test.mbt", "loop_test.mbt",
    "work_test.mbt", "timer_test.mbt", "random_test.mbt", "stream_test.mbt", "thread_test.mbt",
    "process_test.mbt", "fs_event_test.mbt",
  ])
}
