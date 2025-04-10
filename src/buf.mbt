// ///|
// priv type Buf

// ///|
// extern "c" fn Buf::make() -> Buf = "moonbit_uv_buf_make"

// ///|
// extern "c" fn Buf::init(
//   buf : Buf,
//   bytes : Bytes,
//   start_offset : Int,
//   length : UInt
// ) = "moonbit_uv_buf_init"

// ///|
// extern "c" fn Buf::set_len(buf : Buf, len : UInt64) = "moonbit_uv_buf_set_len"

// ///|
// extern "c" fn Buf::set_base(buf : Buf, bytes : Bytes, offset~ : Int = 0) = "moonbit_uv_buf_set_base"

// ///|
// extern "c" fn Buf::get_base(buf : Buf) -> Bytes = "moonbit_uv_buf_get_base"
