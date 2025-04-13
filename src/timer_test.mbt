///|
test "timer" {
  let uv = @uv.Loop::new!()
  let timer = @uv.Timer::new!(uv)
  let mut count = 0
  timer.start!(timeout=100, repeat=100, fn(_) {
    println("Timer fired")
    count += 1
    if count > 10 {
      try {
        timer.stop!()
        timer.close(fn(_) { println("Timer closed") })
      } catch {
        error => println("Error stopping timer: \{error}")
      }
    }
  })
  uv.run!(@uv.RunMode::Default)
  uv.stop()
  uv.close!()
}
