///|
fn raise_option[E : Error](option : E?) -> Unit!E {
  if option is Some(error) {
    raise error
  }
}

///|
test "cat" {
  let uv = @uv.Loop::new!()
  let mut open_error = None
  let mut read_error = None
  let mut write_error = None
  let mut close_error = None
  fn do_close(uv : @uv.Loop, file : @uv.File) {
    try {
      uv.fs_close!(file, fn(_) {  })
    } catch {
      error => close_error = Some(error)
    }
  }

  fn do_write(
    uv : @uv.Loop,
    file : @uv.File,
    bytes : Bytes,
    start : Int,
    count : Int
  ) -> Unit {
    try {
      uv.fs_write!(
        @uv.stdout,
        [bytes[start:start + count]],
        -1,
        fn(_, delta) {
          if delta < count {
            do_write(uv, file, bytes, start + delta, count - delta)
          }
        },
        fn(_, error) { write_error = Some(error) },
      )
    } catch {
      error => write_error = Some(error)
    }
  }

  fn do_read(uv : @uv.Loop, file : @uv.File, bytes : Bytes) -> Unit {
    try {
      uv.fs_read!(
        file,
        [bytes[:]],
        -1,
        fn(_, count) {
          if count == 0 {
            do_close(uv, file)
          } else {
            do_write(uv, file, bytes, 0, count)
          }
        },
        fn(_, errno) {
          read_error = Some(errno)
          do_close(uv, file)
        },
      )
    } catch {
      error => {
        read_error = Some(error)
        do_close(uv, file)
      }
    }
  }

  uv.fs_open!(
    "README.md",
    @uv.OpenFlags::read(),
    0,
    fn(_, file) { do_read(uv, file, Bytes::make(1024, 0)) },
    fn(_, errno) { open_error = Some(errno) },
  )
  uv.run!(@uv.RunMode::Default)
  uv.close!()
  raise_option!(open_error)
  raise_option!(read_error)
  raise_option!(write_error)
  raise_option!(close_error)
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
