///|
type Loop Bytes

///|
extern "c" fn uv_loop_make() -> Loop = "moonbit_uv_loop_make"

///|
extern "c" fn uv_loop_init(loop_ : Loop) -> Int = "moonbit_uv_loop_init"

///|
pub fn Loop::new() -> Loop!Errno {
  let loop_ = uv_loop_make()
  let status = uv_loop_init(loop_)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return loop_
}

///|
extern "c" fn uv_loop_close(loop_ : Loop) -> Int = "moonbit_uv_loop_close"

///|
pub fn Loop::close(loop_ : Loop) -> Unit!Errno {
  let status = uv_loop_close(loop_)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub(all) enum RunMode {
  Default = 0
  Once = 1
  NoWait = 2
}

///|
extern "c" fn uv_run(loop_ : Loop, mode : RunMode) -> Int = "moonbit_uv_run"

///|
pub fn run(self : Loop, mode : RunMode) -> Unit!Errno {
  let status = uv_run(self, mode)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_stop(loop_ : Loop) = "moonbit_uv_stop"

///|
pub fn stop(self : Loop) -> Unit {
  uv_stop(self)
}

///|
extern "c" fn uv_loop_alive(loop_ : Loop) -> Int = "moonbit_uv_loop_alive"

///|
pub fn Loop::alive(loop_ : Loop) -> Bool {
  return uv_loop_alive(loop_) != 0
}
