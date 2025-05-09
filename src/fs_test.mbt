///|
fn raise_option[E : Error](option : E?) -> Unit!E {
  if option is Some(error) {
    raise error
  }
}

///|
fn cat_do_close(uv : @uv.Loop, file : @uv.File, error : Ref[Errno?]) -> Unit {
  try {
    uv.fs_close!(file, fn(_) {  })
  } catch {
    e => error.val = Some(e)
  }
}

///|
fn cat_do_write(
  uv : @uv.Loop,
  file : @uv.File,
  bytes : Bytes,
  start : Int,
  count : Int,
  error : Ref[Errno?]
) -> Unit {
  try {
    uv.fs_write!(
      @uv.stdout(),
      [bytes[start:start + count]],
      fn(_, delta) {
        if delta < count {
          cat_do_write(uv, file, bytes, start + delta, count - delta, error)
        } else {
          cat_do_read(uv, file, bytes, error)
        }
      },
      fn(_, e) { error.val = Some(e) },
    )
  } catch {
    e => error.val = Some(e)
  }
}

///|
fn cat_do_read(
  uv : @uv.Loop,
  file : @uv.File,
  bytes : Bytes,
  error : Ref[Errno?]
) -> Unit {
  try {
    uv.fs_read!(
      file,
      [bytes[:]],
      fn(_, count) {
        if count == 0 {
          cat_do_close(uv, file, error)
        } else {
          cat_do_write(uv, file, bytes, 0, count, error)
        }
      },
      fn(_, errno) {
        error.val = Some(errno)
        cat_do_close(uv, file, error)
      },
    )
  } catch {
    e => {
      error.val = Some(e)
      cat_do_close(uv, file, error)
    }
  }
}

///|
test "cat" {
  let uv = @uv.Loop::new!()
  let error = Ref::new(None)
  uv.fs_open!(
    "README.md",
    @uv.OpenFlags::read(),
    0,
    fn(_, file) { cat_do_read(uv, file, Bytes::make(1024, 0), error) },
    fn(_, e) { error.val = Some(e) },
  )
  uv.run!(Default)
  uv.close!()
  raise_option!(error.val)
}

///|
test "mkdir" {
  let uv = @uv.Loop::new!()
  let mut mkdir_error = None
  let mut rmdir_error = None
  uv.fs_mkdir!(
    "test-dir",
    0,
    fn(_) {
      try {
        uv.fs_rmdir!("test-dir", fn(_) {  }, fn(_, error) {
          rmdir_error = Some(error)
        })
      } catch {
        error => rmdir_error = Some(error)
      }
    },
    fn(_, error) { mkdir_error = Some(error) },
  )
  uv.run!(Default)
  uv.stop()
  uv.close!()
  raise_option!(mkdir_error)
  raise_option!(rmdir_error)
}

///|
test "scandir" {
  struct Entry {
    name : String
    type_ : @uv.DirentType
  } derive(Show, ToJson)
  let uv = @uv.Loop::new!()
  let mut error = None
  let entries = []
  uv.fs_scandir!(
    "test/fixtures",
    0,
    fn(req) {
      while true {
        let dirent = try {
          @uv.fs_scandir_next!(req)
        } catch {
          e => {
            error = Some(e)
            break
          }
        }
        entries.push({ name: dirent.name(), type_: dirent.type_() })
      }
    },
    fn(_, e) { if not(e is Errno(EOF)) { error = Some(e) } },
  )
  uv.run!(Default)
  uv.stop()
  uv.close!()
  @json.inspect!(entries, content=[{ "name": "example.txt", "type_": "File" }])
  raise_option!(error)
}

///|
test "copyfile_unlink" {
  let uv = @uv.Loop::new!()
  let mut error = None
  uv.fs_copyfile!(
    "test/fixtures/example.txt",
    "test/fixtures/example-copy.txt",
    @uv.CopyFileFlags::new(),
    fn(_) {
      try {
        uv.fs_unlink!("test/fixtures/example-copy.txt", fn(_) {  }, fn(_, e) {
          error = Some(e)
        })
      } catch {
        e => error = Some(e)
      }
    },
    fn(_, e) { error = Some(e) },
  )
  uv.run!(Default)
  uv.stop()
  uv.close!()
  raise_option!(error)
}

///|
test "realpath" {
  let uv = @uv.Loop::new!()
  let cwd = @uv.cwd!()
  let errors : Array[Error] = []
  let file = "test/fixtures/example.txt"
  uv.fs_realpath!(
    "test/fixtures/example.txt",
    fn(_, p) {
      try {
        assert_eq!(@async.path!(p), @async.path!([cwd, file]))
      } catch {
        e => errors.push(e)
      }
    },
    fn(_, e) { errors.push(e) },
  )
  uv.run!(Default)
  uv.stop()
  uv.close!()
  for e in errors {
    raise e
  }
}

///|
test "stat" {
  let uv = @uv.Loop::new!()
  let errors : Array[Error] = []
  uv.fs_stat!(
    "test/fixtures/example.txt",
    fn(_, stat) {
      try {
        // It should be a regular file
        assert_true!(stat.is_file())
        // It shouldn't be a directory
        assert_true!(not(stat.is_directory()))
        // Size should be greater than 0
        assert_true!(stat.size() > 0)
      } catch {
        e => errors.push(e)
      }
    },
    fn(_, e) { errors.push(e) },
  )
  uv.run!(Default)
  uv.stop()
  uv.close!()
  for e in errors {
    raise e
  }
}

///|
test "lstat" {
  let uv = @uv.Loop::new!()
  let errors : Array[Error] = []
  uv.fs_lstat!(
    "test/fixtures",
    fn(_, stat) {
      try {
        // It should be a directory;ppp

        assert_true!(stat.is_directory())
        // It shouldn't be a regular file
        assert_true!(not(stat.is_file()))
      } catch {
        e => errors.push(e)
      }
    },
    fn(_, e) { errors.push(e) },
  )
  uv.run!(Default)
  uv.stop()
  uv.close!()
  for e in errors {
    raise e
  }
}

///|
test "fstat" {
  let uv = @uv.Loop::new!()
  let errors : Array[Error] = []
  let mut file_handle : @uv.File? = None
  uv.fs_open!(
    "test/fixtures/example.txt",
    @uv.OpenFlags::read(),
    0,
    fn(_, file) { file_handle = Some(file) },
    fn(_, e) { errors.push(e) },
  )
  uv.run!(Default)
  if file_handle is Some(fh) {
    uv.fs_fstat!(
      fh,
      fn(_, stat) {
        try {
          // It should be a regular file
          assert_true!(stat.is_file())
          // It shouldn't be a directory
          assert_true!(not(stat.is_directory()))
          // Size should be greater than 0
          assert_true!(stat.size() > 0)
        } catch {
          e => errors.push(e)
        }
      },
      fn(_, e) { errors.push(e) },
    )
    uv.run!(Default)
    uv.fs_close!(fh, fn(_) {  })
    uv.run!(Default)
  }
  uv.stop()
  uv.close!()
  for e in errors {
    raise e
  }
}
