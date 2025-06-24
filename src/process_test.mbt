///|
test "spawn" {
  struct MoonVersionItem {
    name : String
  } derive(@json.FromJson)
  struct MoonVersion {
    items : Array[MoonVersionItem]
  } derive(@json.FromJson)
  let uv = @uv.Loop::new()
  let mut error : Error? = None
  let stdout_pipe = @uv.Pipe::new(uv, ipc=false)
  fn do_read(pipe : @uv.Pipe) -> Unit {
    pipe.read_start(
      fn(_, size_hint) { return Bytes::make(size_hint, 0)[:] },
      fn(_, count, bytes) {
        try {
          let content = @encoding.decode(bytes[:count], encoding=UTF8)
          let json = @json.parse(content)
          let version : MoonVersion = @json.from_json(json)
          assert_true(version.items is [{ name: "moon" }])
        } catch {
          e => error = Some(e)
        }
      },
      fn(pipe, e) {
        if not(e is Errno(EOF)) {
          error = Some(e)
        }
        pipe.read_stop() catch {
          e => if error is None { error = Some(e) }
        }
        pipe.close(fn(_) {  })
      },
    ) catch {
      e => {
        error = Some(e)
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
    ["moon", "version", "--json"],
    stdio~,
    fn(child, exit_status, term_signal) {
      try {
        assert_eq(exit_status, 0)
        assert_eq(term_signal, 0)
      } catch {
        e => error = Some(e)
      }
      child.close(fn(_) {  })
    },
  )
  let _ = uv.spawn(options)
  do_read(stdout_pipe)
  uv.run(Default)
  uv.close()
  if error is Some(e) {
    raise e
  }
}
