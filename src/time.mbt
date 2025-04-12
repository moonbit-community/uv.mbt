///|
extern "c" fn uv_hrtime() -> UInt64 = "uv_hrtime"

///|
pub fn hrtime() -> UInt64 {
  uv_hrtime()
}
