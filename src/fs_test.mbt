///|
test "cat" {
  let uv = @uv.Loop::new!()
  let mut open_error = None
  let mut read_error = None
  let mut write_error = None
  fn on_close(_) {
    @uv.stop(uv)
  }

  fn on_write(
    req : @uv.Fs,
    file : @uv.File,
    bufs : Array[@bytes.View]
  ) -> Unit {
    try {
      let result = req.result()
      guard result >= 0 else {
        fail!("Write error: \{@uv.strerror(result.to_int())}")
      }
      uv.fs_read!(file, bufs, -1, fn(req) { on_read(req, file, bufs) })
    } catch {
      error => write_error = Some(error)
    }
  }

  fn on_read(req : @uv.Fs, file : @uv.File, bufs : Array[@bytes.View]) -> Unit {
    try {
      let result = req.result()
      if result < 0 {
        fail!("Read error: \{@uv.strerror(result.to_int())}")
      } else if result == 0 {
        uv.fs_close!(file, fn(req) { on_close(req) })
      } else if result > 0 {
        uv.fs_write!(@uv.stdout, [bufs[0][:result.to_int()]], -1, fn(req) {
          on_write(req, file, bufs)
        })
      }
    } catch {
      error => read_error = Some(error)
    }
  }

  fn on_open(req : @uv.Fs) -> Unit {
    try {
      let file = req.file!()
      let bufs = [Bytes::make(1024, 0)[:]]
      uv.fs_read!(file, bufs, -1, fn(req) { on_read(req, file, bufs) })
    } catch {
      error => open_error = Some(error)
    }
  }

  uv.fs_open!("README.md", @uv.OpenFlags::read(), 0, fn(req) { on_open(req) })
  uv.run!(@uv.RunMode::Default)
  uv.close!()
  if open_error is Some(error) {
    raise error
  }
  if read_error is Some(error) {
    raise error
  }
  if write_error is Some(error) {
    raise error
  }
}
