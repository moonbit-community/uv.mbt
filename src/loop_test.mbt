///|
test "walk" {
  let uv = @uv.Loop::new()
  let idle = @uv.Idle::new(uv)
  let mut error = None
  fn errno(errno : @uv.Errno) {
    uv.stop()
    error = Some(errno)
  }

  idle.start(fn(_) { idle.stop() catch { error => errno(error) } })
  let mut count = 0
  uv.walk(fn(handle) {
    count += 1
    handle.close(_ => ())
  })
  @json.inspect(count, content=1)
  uv.run(Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
}
