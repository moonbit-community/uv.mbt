///|
type Random

///|
extern "c" fn uv_random_make() -> Random = "moonbit_uv_random_make"

///|
extern "c" fn uv_random(
  self : Loop,
  req : Random,
  buffer : Bytes,
  buffer_offset : Int,
  buffer_length : Int,
  flags : Int,
  random_cb : (Random, Int, Int) -> Unit
) -> Int = "moonbit_uv_random"

///|
pub fn random(
  self : Loop,
  buffer : @bytes.View,
  flags : Int,
  random_cb : (Random, @bytes.View) -> Unit,
  error_cb : (Random, Errno) -> Unit
) -> Unit!Errno {
  fn uv_random_cb(random, status, length) {
    if status < 0 {
      error_cb(random, Errno::of_int(status))
    } else {
      random_cb(random, buffer[:length])
    }
  }

  let req = uv_random_make()
  let buffer_offset = buffer.start_offset()
  let buffer_length = buffer.length()
  let buffer = buffer.data()
  let status = uv_random(
    self, req, buffer, buffer_offset, buffer_length, flags, uv_random_cb,
  )
  if status < 0 {
    raise Errno::of_int(status)
  }
}
