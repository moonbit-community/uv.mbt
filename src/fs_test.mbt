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
  fn on_close(_) {
    @uv.stop(uv)
  }

  fn do_write(file : @uv.File, bytes : Bytes, start : Int, count : Int) -> Unit {
    try {
      if count == 0 {
        uv.fs_close!(file, fn(req) { on_close(req) })
      } else {
        uv.fs_write!(
          @uv.stdout,
          [bytes[start:start + count]],
          -1,
          fn(_, delta) {
            if delta < count {
              do_write(file, bytes, start + delta, count - delta)
            } else {
              do_read(file, bytes)
            }
          },
          fn(_, error) { write_error = Some(error) },
        )
      }
    } catch {
      error => read_error = Some(error)
    }
  }

  fn do_read(file : @uv.File, bytes : Bytes) -> Unit {
    try {
      uv.fs_read!(
        file,
        [bytes[:]],
        -1,
        fn(_, count) {
          do_write(file, bytes, 0, count)
        },
        fn(_, errno) { read_error = Some(errno) },
      )
    } catch {
      error => read_error = Some(error)
    }
  }

  uv.fs_open!(
    "README.md",
    @uv.OpenFlags::read(),
    0,
    fn(_, file) { do_read(file, Bytes::make(1024, 0)) },
    fn(_, errno) { open_error = Some(errno) },
  )
  uv.run!(@uv.RunMode::Default)
  uv.close!()
  raise_option!(open_error)
  raise_option!(read_error)
  raise_option!(write_error)
}
