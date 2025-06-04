///|
type Thread

///|
extern "c" fn uv_thread_make() -> Thread = "moonbit_uv_thread_make"

///|
extern "c" fn uv_thread_create(thread : Thread, cb : () -> Unit) -> Int = "moonbit_uv_thread_create"

///|
pub fn Thread::new(cb : () -> Unit) -> Thread!Errno {
  let thread = uv_thread_make()
  let status = uv_thread_create(thread, cb)
  if status != 0 {
    raise Errno::of_int(status)
  }
  return thread
}

///|
extern "c" fn uv_thread_join(thread : Thread) -> Int = "moonbit_uv_thread_join"

///|
extern "c" fn uv_thread_self(thread : Thread) -> Int = "moonbit_uv_thread_self"

///|
extern "c" fn uv_thread_equal(thread : Thread, other : Thread) -> Int = "moonbit_uv_thread_equal"

///|
pub impl Eq for Thread with op_equal(self : Thread, other : Thread) -> Bool {
  return uv_thread_equal(self, other) != 0
}

///|
extern "c" fn uv_thread_copy(thread : Thread, other : Thread) -> Unit = "moonbit_uv_thread_copy"

///|
pub fn Thread::join(self : Thread) -> Unit!Errno {
  let status = uv_thread_join(self)
  if status != 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn Thread::self() -> Thread!Errno {
  let thread = uv_thread_make()
  let status = uv_thread_self(thread)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return thread
}

///|
pub fn Thread::equal(self : Thread, other : Thread) -> Bool {
  return uv_thread_equal(self, other) != 0
}

///|
pub impl Share for Thread with share(self : Thread) -> Thread {
  let other = uv_thread_make()
  uv_thread_copy(self, other)
  return other
}
