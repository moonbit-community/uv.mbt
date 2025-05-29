///|
test "native_thread_test" {
  let thread = Thread::new!(fn() -> Unit { println("Hello from thread!") })
  thread.join!()
  let current = Thread::self()
  let thread2 = Thread::new!(fn() {
    try {
      let self_thread = Thread::self()
      println("Is it the main thread? \{Thread::equal(self_thread, current)}")
    } catch {
      e => println("Error: \{e}")
    }
  })
  thread2.join!()
}
