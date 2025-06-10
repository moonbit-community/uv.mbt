
///|
test "native_thread_test" {
  let buffer = []
  let thread = Thread::new(fn() -> Unit { buffer.push("thread!") })
  buffer.push("main")
  thread.join()
  buffer.push("joined")
  @json.inspect(buffer, content=["main", "thread!", "joined"])
  assert_true(Thread::self() == Thread::self())
  let current = Thread::self()
  let mut error = None
  let thread = Thread::new(fn() {
    try assert_false(Thread::self() == current) catch {
      e => error = Some(e)
    }
  })
  thread.join()
  if error is Some(e) {
    raise e
  }
}
