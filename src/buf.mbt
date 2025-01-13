///|
pub type Buf

///|
pub extern "c" fn buf_alloc() -> Buf = "moonbit_uv_buf_alloc"

///|
pub extern "c" fn buf_init(
  buf : Buf,
  bytes : Bytes,
  offset : Int,
  length : Int
) -> Unit = "moonbit_uv_buf_init"

///|
pub extern "c" fn buf_set_len(buf : Buf, len : UInt64) -> Unit = "moonbit_uv_buf_set_len"

///|
pub extern "c" fn buf_get(buf : Buf) -> Bytes = "moonbit_uv_buf_get"

///|
pub extern "c" fn buf_free(buf : Buf) -> Unit = "moonbit_uv_buf_free"
