///|
type Timer

///|
pub extern "c" fn timer_alloc() -> Timer = "moonbit_uv_timer_alloc"

///|
pub extern "c" fn timer_init(loop_ : Loop, timer : Timer) -> Int = "uv_timer_init"

///|
pub extern "c" fn timer_start(
  timer : Timer,
  cb : (Timer) -> Unit,
  timeout : UInt64,
  repeat : UInt64
) -> Int = "uv_timer_start"

///|
pub extern "c" fn timer_stop(timer : Timer) -> Int = "uv_timer_stop"

///|
pub extern "c" fn timer_set_repeat(timer : Timer, repeat : UInt64) -> Unit = "uv_timer_set_repeat"

///|
pub extern "c" fn timer_get_repeat(timer : Timer) -> UInt64 = "uv_timer_get_repeat"

///|
pub extern "c" fn timer_get_due_in(timer : Timer) -> UInt64 = "uv_timer_get_due_in"
