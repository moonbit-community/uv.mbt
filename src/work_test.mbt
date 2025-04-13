///|
fn fib(n : Int) -> Int {
  match n {
    0 => return 0
    1 => return 1
    n => fib(n - 1) + fib(n - 2)
  }
}

///|
test "work" {
  ignore(fib(40))
  let start = @uv.hrtime()
  ignore(fib(40))
  let baseline = @uv.hrtime() - start
  let uv = @uv.Loop::new!()
  let mutex = @uv.Mutex::new!()
  let mut work_error = None
  let start = @uv.hrtime()
  for i in 0..<2 {
    let mutex = mutex.copy()
    uv.queue_work!(fn(_) {
      ignore(fib(40))
    }, fn(_) {  }, fn(_, error) {
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
  assert_true!(elapsed < 3UL * baseline / 2UL)
}
