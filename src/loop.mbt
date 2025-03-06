///|
extern type Loop

///|
pub extern "c" fn default_loop() -> Loop = "moonbit_uv_default_loop"

///|
pub extern "c" fn loop_alloc() -> Loop = "moonbit_uv_loop_alloc"

///|
pub extern "c" fn loop_init(loop_ : Loop) -> Int = "moonbit_uv_loop_init"

///|
pub fn Loop::init() -> Loop!Errno {
  let loop_ = loop_alloc()
  let rc = loop_init(loop_)
  if rc < 0 {
    errno!(rc)
  }
  return loop_
}

///|
pub extern "c" fn loop_free(loop_ : Loop) -> Unit = "moonbit_uv_loop_free"

///|
pub extern "c" fn loop_close(loop_ : Loop) -> Int = "moonbit_uv_loop_close"

///|
pub extern "c" fn run(loop_ : Loop, mode : Int) -> Int = "moonbit_uv_run"

pub extern "c" fn stop(loop_ : Loop) -> Unit = "moonbit_uv_stop"

///|
pub const RUN_DEFAULT = 0

///|
pub const RUN_ONCE = 1

///|
pub const RUN_NOWAIT = 2

///|
pub extern "c" fn loop_alive(loop_ : Loop) -> Int = "moonbit_uv_loop_alive"
