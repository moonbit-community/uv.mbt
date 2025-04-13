///|
type Work

///|
extern "c" fn uv_work_make() -> Work = "moonbit_uv_work_make"

///|
extern "c" fn uv_queue_work(
  self : Loop,
  req : Work,
  work_cb : (Work) -> Unit,
  after_cb : (Work, Int) -> Unit
) -> Int = "moonbit_uv_queue_work"

///|
pub fn queue_work(
  self : Loop,
  work_cb : (Work) -> Unit,
  after_cb : (Work) -> Unit,
  error_cb : (Work, Errno) -> Unit
) -> Unit!Errno {
  let req = uv_work_make()
  let status = uv_queue_work(self, req, fn(req) { work_cb(req) }, fn(
    req,
    status
  ) {
    if status < 0 {
      error_cb(req, Errno::of_int(status))
    } else {
      after_cb(req)
    }
  })
  if status < 0 {
    raise Errno::of_int(status)
  }
}
