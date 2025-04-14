///|
test "spawn" {
  let uv = @uv.Loop::new!()
  let mut test_exit_status = None
  let mut test_term_signal = None
  let mut read_error = None
  let mut write_error = None
  let mut stop_error = None
  let stdout_pipe = @uv.Pipe::new!(uv, ipc=true)
  fn do_write(bytes : @bytes.View, start : Int, count : Int) -> Unit {
    try {
      uv.fs_write!(
        @uv.stdout(),
        [bytes[start:start + count]],
        -1,
        fn(_, delta) {
          if delta < count {
            do_write(bytes, start + delta, count - delta)
          }
        },
        fn(_, error) { write_error = Some(error) },
      )
    } catch {
      error => write_error = Some(error)
    }
  }

  fn do_read(pipe : @uv.Pipe) -> Unit {
    try {
      pipe.read_start!(
        fn(_, size_hint) { return Bytes::make(size_hint, 0)[:] },
        fn(_, count, bytes) { do_write(bytes, 0, count) },
        fn(pipe, error) {
          if not(error is EOF) {
            read_error = Some(error)
          }
          try {
            pipe.read_stop!()
          } catch {
            error => stop_error = Some(error)
          }
          pipe.close(fn(_) {  })
        },
      )
    } catch {
      error => {
        read_error = Some(error)
        pipe.close(fn(_) {  })
      }
    }
  }

  let stdio = [
    @uv.StdioContainer::ignore(),
    @uv.StdioContainer::create_pipe(stdout_pipe.to_stream(), writable=true),
  ]
  let options = @uv.ProcessOptions::new(
    "moon",
    ["moon", "version", "--all"],
    stdio~,
    fn(child, exit_status, term_signal) {
      test_exit_status = Some(exit_status)
      test_term_signal = Some(term_signal)
      child.close(fn(_) {  })
    },
  )
  let _ = uv.spawn!(options)
  do_read(stdout_pipe)
  uv.run!(Default)
  uv.stop()
  uv.close!()
  inspect!(test_exit_status, content="Some(0)")
  inspect!(test_term_signal, content="Some(0)")
  raise_option!(read_error)
  raise_option!(write_error)
  raise_option!(stop_error)
}
