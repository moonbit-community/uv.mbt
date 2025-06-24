///|
type Timer

///|
pub impl ToHandle for Timer with to_handle(self : Timer) -> Handle = "%identity"

///|
pub impl ToHandle for Timer with of_handle(self : Handle) -> Timer = "%identity"

///|
extern "c" fn uv_timer_make() -> Timer = "moonbit_uv_timer_make"

///|
extern "c" fn uv_timer_init(uv : Loop, timer : Timer) -> Int = "moonbit_uv_timer_init"

///|
pub fn Timer::new(self : Loop) -> Timer raise Errno {
  let timer = uv_timer_make()
  let status = uv_timer_init(self, timer)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return timer
}

///|
extern "c" fn uv_timer_start(
  timer : Timer,
  cb : (Timer) -> Unit,
  // We shall never use Int/UInt for time, even in MoonBit.
  timeout : UInt64,
  repeat : UInt64
) -> Int = "moonbit_uv_timer_start"

///|
pub fn Timer::start(
  self : Timer,
  timeout~ : UInt64,
  repeat~ : UInt64,
  cb : (Timer) -> Unit
) -> Unit raise Errno {
  let status = uv_timer_start(self, cb, timeout, repeat)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_timer_stop(timer : Timer) -> Int = "moonbit_uv_timer_stop"

///|
pub fn Timer::stop(self : Timer) -> Unit raise Errno {
  let status = uv_timer_stop(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_timer_set_repeat(timer : Timer, repeat : UInt64) = "moonbit_uv_timer_set_repeat"

///|
pub fn Timer::set_repeat(self : Timer, repeat : UInt64) -> Unit {
  uv_timer_set_repeat(self, repeat)
}

///|
extern "c" fn uv_timer_get_repeat(timer : Timer) -> UInt64 = "moonbit_uv_timer_get_repeat"

///|
pub fn Timer::get_repeat(self : Timer) -> UInt64 {
  uv_timer_get_repeat(self)
}

///|
extern "c" fn uv_timer_get_due_in(timer : Timer) -> UInt64 = "moonbit_uv_timer_get_due_in"

///|
pub fn Timer::get_due_in(self : Timer) -> UInt64 {
  uv_timer_get_due_in(self)
}
