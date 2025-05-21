///|
type Thread

///|
extern "c" fn uv_thread_make() -> Thread = "moonbit_uv_thread_make"

///|
extern "c" fn uv_thread_create(self : Thread, callback : () -> Unit) -> Int = "moonbit_uv_thread_create"

///|
pub fn Thread::new(callback : () -> Unit) -> Thread!Errno {
  let thread = uv_thread_make()
  let status = uv_thread_create(thread, callback)
  if status != 0 {
    raise Errno::of_int(status)
  }
  return thread
}

///|
extern "c" fn uv_thread_join(self : Thread) -> Int = "moonbit_uv_thread_join"

///|
extern "c" fn uv_thread_self(self : Thread) -> Unit = "moonbit_uv_thread_self"

///|
extern "c" fn uv_thread_equal(self : Thread, other : Thread) -> Int = "moonbit_uv_thread_equal"

///|
extern "c" fn uv_thread_copy(self : Thread, other : Thread) -> Unit = "moonbit_uv_thread_copy"

///|
pub fn Thread::join(self : Thread) -> Unit!Errno {
  let status = uv_thread_join(self)
  if status != 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn Thread::current() -> Thread {
  let thread = uv_thread_make()
  uv_thread_self(thread)
  return thread
}

///|
pub fn Thread::equal(self : Thread, other : Thread) -> Bool {
  return uv_thread_equal(self, other) != 0
}

///|
pub impl Copy for Thread with copy(self : Thread) -> Thread {
  let other = uv_thread_make()
  uv_thread_copy(self, other)
  return other
}
