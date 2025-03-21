///|
type Loop Bytes

///|
pub extern "c" fn loop_alloc() -> Loop = "moonbit_uv_loop_alloc"

///|
pub extern "c" fn loop_init(loop_ : Loop) -> Int = "moonbit_uv_loop_init"

///|
pub extern "c" fn loop_close(loop_ : Loop) -> Int = "moonbit_uv_loop_close"

///|
pub(all) enum RunMode {
  Default = 0
  Once = 1
  NoWait = 2
}

///|
pub extern "c" fn run(loop_ : Loop, mode : RunMode) -> Int = "moonbit_uv_run"

///|
pub extern "c" fn stop(loop_ : Loop) -> Unit = "moonbit_uv_stop"

///|
pub extern "c" fn loop_alive(loop_ : Loop) -> Int = "moonbit_uv_loop_alive"
