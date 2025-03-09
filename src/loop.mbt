///|
type Loop Bytes

///|
pub extern "c" fn loop_alloc() -> Loop = "moonbit_uv_loop_alloc"

///|
pub extern "c" fn loop_init(self : Loop) -> Int = "moonbit_uv_loop_init"

///|
pub fn Loop::new() -> Unit!Errno {
  let self = loop_alloc()
  loop_init(self) |> errno!()
}

///|
pub extern "c" fn loop_close(loop_ : Loop) -> Int = "moonbit_uv_loop_close"

///|
pub fn Loop::close(self : Loop) -> Unit!Errno {
  loop_close(self) |> errno!()
}

///|
pub const RUN_DEFAULT : Int = 0

///|
pub const RUN_ONCE : Int = 1

///|
pub const RUN_NOWAIT : Int = 2

///|
pub extern "c" fn run(loop_ : Loop, mode : Int) -> Int = "moonbit_uv_run"

///|
pub extern "c" fn stop(loop_ : Loop) -> Unit = "moonbit_uv_stop"

///|
pub extern "c" fn loop_alive(self : Loop) -> Int = "moonbit_uv_loop_alive"

pub fn Loop::alive(self : Loop) -> Bool {
  loop_alive(self) != 0
}
