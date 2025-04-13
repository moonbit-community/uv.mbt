///|
test "work" {
  let uv = @uv.Loop::new!()
  let mutex = @uv.Mutex::new!()
  let mut work_error = None
  let start = @uv.hrtime()
  for i in 0..<2 {
    let mutex = mutex.copy()
    uv.queue_work!(fn(_) { @uv.sleep(50) }, fn(_) {  }, fn(_, error) {
      mutex.lock()
      work_error = Some(error)
      mutex.unlock()
    })
  }
  uv.run!(Default)
  uv.stop()
  uv.close!()
  raise_option!(work_error)
  let elapsed = @uv.hrtime() - start
  assert_true!(elapsed < 100000000)
}
