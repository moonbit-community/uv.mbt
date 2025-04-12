///|
type Idle Bytes

///|
pub impl ToHandle for Idle with to_handle(idle : Idle) -> Handle = "%identity"

///|
pub impl ToHandle for Idle with of_handle(handle : Handle) -> Idle = "%identity"

///|
extern "c" fn uv_idle_make() -> Idle = "moonbit_uv_idle_make"

///|
extern "c" fn uv_idle_init(loop_ : Loop, idle : Idle) -> Int = "moonbit_uv_idle_init"

///|
pub fn Idle::new(self : Loop) -> Idle!Errno {
  let idle = uv_idle_make()
  let status = uv_idle_init(self, idle)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return idle
}

///|
extern "c" fn uv_idle_start(idle : Idle, cb : (Idle) -> Unit) -> Int = "moonbit_uv_idle_start"

///|
extern "c" fn uv_idle_stop(idle : Idle) -> Int = "moonbit_uv_idle_stop"

///|
pub fn Idle::start(self : Idle, cb : (Idle) -> Unit) -> Unit!Errno {
  let status = uv_idle_start(self, fn(idle) { cb(idle) })
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn Idle::stop(self : Idle) -> Unit!Errno {
  let status = uv_idle_stop(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
