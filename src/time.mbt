///|
extern "c" fn uv_hrtime() -> UInt64 = "moonbit_uv_hrtime"

///|
pub fn hrtime() -> UInt64 {
  uv_hrtime()
}

///|
extern "c" fn uv_sleep(milliseconds : UInt) = "moonbit_uv_sleep"

///|
pub fn sleep(milliseconds : UInt) -> Unit {
  uv_sleep(milliseconds)
}
