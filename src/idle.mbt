///|
extern type Idle

///|
impl ToHandle for Idle with to_handle(self : Idle) -> Handle = "%identity"

///|
pub extern "c" fn idle_alloc() -> Idle = "moonbit_uv_idle_alloc"

///|
pub extern "c" fn idle_init(loop_ : Loop, idle : Idle) -> Int = "moonbit_uv_idle_init"

///|
pub fn Idle::new(loop_ : Loop) -> Idle!Errno {
  let idle = idle_alloc()
  idle_init(loop_, idle) |> errno!()
  idle
}

///|
pub fn Loop::idle(self : Loop) -> Idle!Errno {
  let idle = idle_alloc()
  idle_init(self, idle) |> errno!()
  idle
}

///|
pub extern "c" fn idle_start(idle : Idle, cb : (Idle) -> Unit) -> Int = "moonbit_uv_idle_start"

pub async fn Idle::start(self : Idle) -> Unit!Errno {
  async_suspend_with_error!!(fn(resolve, reject) {
    let result = idle_start(self, fn(_) {
      let result = idle_stop(self)
      if (result < 0) {
        reject(Errno(result))
      } else {
        resolve(())
      }
    })
    if result < 0 {
      reject(Errno(result))
    }
  })
}

///|
pub extern "c" fn idle_stop(idle : Idle) -> Int = "moonbit_uv_idle_stop"

///|
pub extern "c" fn idle_free(idle : Idle) -> Unit = "moonbit_uv_idle_free"
