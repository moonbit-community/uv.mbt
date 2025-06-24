///|
test "work" {
  let uv = @uv.Loop::new()
  let mutex = @uv.Mutex::new()
  let mut error = None
  for i in 0..<2 {
    let mutex = mutex.share()
    uv.queue_work(() => @uv.sleep(50), () => (), fn(e) {
      mutex.lock()
      error = Some(e)
      mutex.unlock()
    })
    |> ignore()
  }
  uv.run(Default)
  uv.close()
  if error is Some(e) {
    raise e
  }
}
