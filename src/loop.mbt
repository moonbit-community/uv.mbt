///|
type Loop

///|
pub extern "c" fn default_loop() -> Loop = "moonbit_uv_default_loop"

///|
pub extern "c" fn loop_alloc() -> Loop = "moonbit_uv_loop_alloc"

///|
pub extern "c" fn loop_init(loop_ : Loop) -> Int = "moonbit_uv_loop_init"

///|
pub extern "c" fn loop_free(loop_ : Loop) -> Unit = "moonbit_uv_loop_free"

///|
pub extern "c" fn loop_close(loop_ : Loop) -> Int = "moonbit_uv_loop_close"

///|
pub extern "c" fn run(loop_ : Loop, mode : Int) -> Int = "moonbit_uv_run"

///|
pub const UV_RUN_DEFAULT = 0

///|
pub const UV_RUN_ONCE = 1

///|
pub const UV_RUN_NOWAIT = 2
