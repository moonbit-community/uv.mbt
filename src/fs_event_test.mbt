///|
test "fs_event" {
  let uv = @uv.Loop::new!()
  let fs_event = @uv.FsEvent::new!(uv)
  let errors : Array[Error] = []
  let events : Array[(String?, Array[FsEventType])] = []
  fs_event.start!(
    "test/fixtures/",
    FsEventFlags::new(),
    fn(_, name, types) { events.push((name, types)) },
    fn(_, _, errno) {
      errors.push(errno)
      try fs_event.stop!() catch {
        e => errors.push(e)
      }
      fs_event.close(fn(_) {  })
    },
  )
  uv.fs_open!(
    "test/fixtures/test.txt",
    @uv.OpenFlags::write(create=true),
    0o644,
    fn(_, file) {
      try
        uv.fs_write!(
          file,
          [b"Hello, world!"],
          fn(_, _) {
            try
              uv.fs_close!(file, fn(_) {
                try
                  uv.fs_unlink!(
                    "test/fixtures/test.txt",
                    fn(_) {
                      try fs_event.stop!() catch {
                        e => errors.push(e)
                      }
                      fs_event.close(fn(_) {  })
                    },
                    fn(_, e) { errors.push(e) },
                  ) catch {
                  e => errors.push(e)
                }
              }) catch {
              e => errors.push(e)
            }
          },
          fn(_, errno) { errors.push(errno) },
        ) catch {
        e => errors.push(e)
      }
    },
    fn(_, errno) { errors.push(errno) },
  )
  uv.run!(Default)
  uv.stop()
  uv.close!()
  for e in errors {
    raise e
  }
  @json.inspect!(events, content=[
    [["test.txt"], ["Rename"]],
    [["test.txt"], ["Change"]],
    [["test.txt"], ["Rename"]],
  ])
}
