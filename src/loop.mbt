///|
extern type Loop

///|
extern "c" fn Loop::default() -> Loop = "moonbit_uv_default_loop"

///|
extern "c" fn Loop::alloc() -> Loop = "moonbit_uv_loop_alloc"

///|
extern "c" fn Loop::init(self : Loop) -> Int = "moonbit_uv_loop_init"

///|
pub fn Loop::new() -> Loop!Errno {
  let loop_ = Loop::alloc()
  loop_.init() |> errno!()
  return loop_
}

///|
extern "c" fn Loop::_close(loop_ : Loop) -> Int = "moonbit_uv_loop_close"

///|
pub fn Loop::close(self : Loop) -> Unit!Errno {
  self._close() |> errno!()
}

///|
pub(all) enum RunMode {
  Default = 0
  Once = 1
  NoWait = 2
}

///|
extern "c" fn _run(loop_ : Loop, mode : RunMode) -> Int = "moonbit_uv_run"

///|
pub fn run(loop_ : Loop, mode : RunMode) -> Unit!Errno {
  _run(loop_, mode) |> errno!()
}

///|
pub extern "c" fn stop(loop_ : Loop) -> Unit = "moonbit_uv_stop"

///|
extern "c" fn Loop::_alive(self : Loop) -> Int = "moonbit_uv_loop_alive"

pub fn Loop::alive(self : Loop) -> Bool {
  self._alive() != 0
}
