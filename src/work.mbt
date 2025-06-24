///|
type Work

///|
extern "c" fn uv_work_make() -> Work = "moonbit_uv_work_make"

///|
extern "c" fn uv_queue_work(
  uv : Loop,
  req : Work,
  work_cb : (Work) -> Unit,
  after_cb : (Work, Int) -> Unit
) -> Int = "moonbit_uv_queue_work"

///|
pub fn Loop::queue_work(
  self : Loop,
  work_cb : () -> Unit,
  after_cb : () -> Unit,
  error_cb : (Errno) -> Unit
) -> Work raise Errno {
  let req = uv_work_make()
  let status = uv_queue_work(self, req, fn(_) { work_cb() }, fn(_, status) {
    if status < 0 {
      error_cb(Errno::of_int(status))
    } else {
      after_cb()
    }
  })
  if status < 0 {
    raise Errno::of_int(status)
  }
  req
}

///|
pub impl ToReq for Work with to_req(self : Work) -> Req = "%identity"

///|
pub impl Cancelable for Work
