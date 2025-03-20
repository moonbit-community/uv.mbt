///|
type Idle Bytes

///|
impl ToHandle for Idle with to_handle(self : Idle) -> Handle = "%identity"

///|
extern "c" fn idle_alloc() -> Idle = "moonbit_uv_idle_alloc"

///|
extern "c" fn idle_init(loop_ : Loop, idle : Idle) -> Int = "moonbit_uv_idle_init"

///|
pub fn idle_new(loop_ : Loop) -> Idle!Errno {
  let idle = idle_alloc()
  idle_init(loop_, idle) |> errno!()
  idle
}

///|
// pub fn Idle::spawn(loop_ : Loop, f : async (Idle) -> Unit!) -> Unit {
//   spawn(fn() {
//     let idle = Idle::new!(loop_)
//     scope!!(fn() { spawn(fn() { f!!(idle) }) }) |> ignore()
//     idle.close!!()
//   })
// }

///|
// pub async fn Loop::idle(self : Loop) -> Unit!Errno {
//   async_suspend_with_error!!(fn(resolve, reject) {
//     let idle = uv_idle_alloc()
//     let result = uv_idle_init(self, idle)
//     if result < 0 {
//       reject(Errno(result))
//     } else {
//       idle_start(idle, fn(_) {
//         idle_stop(idle) |> ignore()
//         close(idle.to_handle(), fn(_) {  })
//         resolve(())
//       })
//       |> ignore()
//     }
//   })
// }

///|
extern "c" fn idle_start(idle : Idle, cb : (Idle) -> Unit) -> Int = "moonbit_uv_idle_start"

///|
pub fn Idle::start(self : Idle, f : async (async () -> Unit) -> Unit) -> Unit! {
  let mut resolve = fn(_) {  }
  let yield_ = async fn() { async_suspend!!(fn(k) { resolve = k }) }
  async_run(fn() {
    yield_!!()
    f!!(yield_)
    idle_stop(self) |> ignore()
  })
  idle_start(self, fn(_) { resolve(()) }) |> errno!()
}

///|
pub extern "c" fn idle_stop(idle : Idle) -> Int = "moonbit_uv_idle_stop"

///|
// pub async fn Idle::wait(self : Idle) -> Unit {
//   async_suspend!!(fn(resolve) {
//     uv_idle_start(self, fn(_) {
//       uv_idle_stop(self) |> ignore()
//       resolve(())
//     })
//     |> ignore()
//   })
// }

///|
async fn Idle::close(self : Idle) -> Unit {
  async_suspend!!(fn(resolve) { close(self.to_handle(), fn(_) { resolve(()) }) })
}
