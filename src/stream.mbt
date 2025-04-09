///|
extern type Stream

///|
pub fn Stream::to_handle(self : Stream) -> Handle = "%identity"

///|
extern "c" fn read_start(
  stream : Stream,
  alloc_cb : (Handle, UInt64, Buf) -> Unit,
  read_cb : (Stream, Int64, Buf) -> Unit
) -> Int = "moonbit_uv_read_start"

///|
pub extern "c" fn read_stop(stream : Stream) -> Int = "moonbit_uv_read_stop"

///|
type Write

///|
pub extern "c" fn write_alloc() -> Write = "moonbit_uv_write_alloc"

///|
extern "c" fn write(
  write : Write,
  handle : Stream,
  bufs : FixedArray[Buf],
  cb : (Write, Int) -> Unit
) -> Int = "moonbit_uv_write"
