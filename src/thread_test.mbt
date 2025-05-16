///|
test "native_thread_test" {
  let thread = Thread::new!(fn() -> Unit { println("Hello from thread!") })
  thread.join!()
  let current = Thread::current()
  let thread2 = Thread::new!(fn() -> Unit {
    let self_thread = Thread::current()
    println("Is it the main thread? \{Thread::equal(self_thread, current)}")
  })
  thread2.join!()
}
