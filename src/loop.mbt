///|
type Loop Bytes

///|
pub extern "c" fn loop_alloc() -> Loop = "moonbit_uv_loop_alloc"

///|
pub extern "c" fn loop_init(self : Loop) -> Int = "moonbit_uv_loop_init"

///|
pub fn Loop::new() -> Loop!Errno {
  let self = loop_alloc()
  loop_init(self) |> errno!()
  self
}

///|
pub extern "c" fn loop_close(loop_ : Loop) -> Int = "moonbit_uv_loop_close"

///|
pub fn Loop::close(self : Loop) -> Unit!Errno {
  loop_close(self) |> errno!()
}

///|
pub(all) enum RunMode {
  Default = 0
  Once = 1
  NoWait = 2
}

///|
pub extern "c" fn uv_run(loop_ : Loop, mode : RunMode) -> Int = "moonbit_uv_run"

///|
pub fn run(self : Loop, mode : RunMode) -> Unit!Errno {
  uv_run(self, mode) |> errno!()
}

///|
pub extern "c" fn uv_stop(loop_ : Loop) -> Unit = "moonbit_uv_stop"

pub extern "c" fn stop(loop_ : Loop) -> Unit = "moonbit_uv_stop"

///|
pub extern "c" fn uv_loop_alive(self : Loop) -> Int = "moonbit_uv_loop_alive"

///|
pub fn Loop::alive(self : Loop) -> Bool {
  uv_loop_alive(self) != 0
}
