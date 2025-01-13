///|
pub type Buf

///|
pub extern "c" fn buf_alloc() -> Buf = "moonbit_uv_buf_alloc"

///|
pub extern "c" fn buf_init(
  buf : Buf,
  bytes : Bytes,
  start : Int
) -> Unit = "moonbit_uv_buf_init"

///|
pub extern "c" fn buf_set_base(buf : Buf, base : Bytes) -> Int = "moonbit_uv_buf_set_base"

///|
pub extern "c" fn buf_set_len(buf : Buf, len : UInt64) -> Unit = "moonbit_uv_buf_set_len"

pub extern "c" fn buf_get(buf : Buf, offset : Int, length : Int) -> Bytes = "moonbit_uv_buf_get"

///|
pub extern "c" fn buf_free(buf : Buf) -> Unit = "moonbit_uv_buf_free"
