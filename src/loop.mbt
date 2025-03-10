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
extern "c" fn _run(loop_ : Loop, mode : RunMode) -> Int = "moonbit_uv_run"

///|
pub fn run(self : Loop, mode : RunMode, f : async () -> Unit) -> Unit!Errno {
  async_run(f)
  _run(self, mode) |> errno!()
}

///|
pub extern "c" fn stop(loop_ : Loop) -> Unit = "moonbit_uv_stop"

///|
pub extern "c" fn loop_alive(self : Loop) -> Int = "moonbit_uv_loop_alive"

///|
pub fn Loop::alive(self : Loop) -> Bool {
  loop_alive(self) != 0
}
