///|
test "timer" {
  let uv = @uv.Loop::new()
  let mut error : Error? = None
  let timer = @uv.Timer::new(uv)
  let mut count = 0
  timer.start(timeout=100, repeat=100, fn(_) {
    count += 1
    if count > 10 {
      try {
        timer.stop()
        timer.close(fn(_) {  })
      } catch {
        errno => error = Some(errno)
      }
    }
  })
  uv.run(@uv.RunMode::Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
}
