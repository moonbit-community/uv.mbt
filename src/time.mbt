///|
extern "c" fn uv_hrtime() -> UInt64 = "uv_hrtime"

///|
pub fn hrtime() -> UInt64 {
  uv_hrtime()
}

///|
extern "c" fn uv_sleep(milliseconds : UInt64) = "uv_sleep"

///|
pub fn sleep(milliseconds : UInt64) -> Unit {
  uv_sleep(milliseconds)
}
