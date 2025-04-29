///|
test "spawn" {
  let uv = @uv.Loop::new!()
  let errors : Array[Error] = []
  let stdout_pipe = @uv.Pipe::new!(uv, ipc=false)
  fn do_write(bytes : @bytes.View, start : Int, count : Int) -> Unit {
    try {
      uv.fs_write!(
        @uv.stdout(),
        [bytes[start:start + count]],
        fn(_, delta) {
          if delta < count {
            do_write(bytes, start + delta, count - delta)
          }
        },
        fn(_, error) { errors.push(error) },
      )
    } catch {
      error => errors.push(error)
    }
  }

  fn do_read(pipe : @uv.Pipe) -> Unit {
    try {
      pipe.read_start!(
        fn(_, size_hint) { return Bytes::make(size_hint, 0)[:] },
        fn(_, count, bytes) { do_write(bytes, 0, count) },
        fn(pipe, error) {
          if not(error is Errno(EOF)) {
            errors.push(error)
          }
          try {
            pipe.read_stop!()
          } catch {
            error => errors.push(error)
          }
          pipe.close(fn(_) {  })
        },
      )
    } catch {
      error => {
        errors.push(error)
        pipe.close(fn(_) {  })
      }
    }
  }

  let stdio = [
    @uv.StdioContainer::ignore(),
    @uv.StdioContainer::create_pipe(stdout_pipe, writable=true),
    @uv.StdioContainer::inherit_file(@uv.stderr()),
  ]
  let options = @uv.ProcessOptions::new(
    "moon",
    ["moon", "version", "--all"],
    stdio~,
    fn(child, exit_status, term_signal) {
      try {
        assert_eq!(exit_status, 0)
        assert_eq!(term_signal, 0)
      } catch {
        error => errors.push(error)
      }
      child.close(fn(_) {  })
    },
  )
  let _ = uv.spawn!(options)
  do_read(stdout_pipe)
  uv.run!(Default)
  uv.stop()
  uv.close!()
  for error in errors {
    raise error
  }
}
