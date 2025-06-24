///|
type Req

///|
pub trait ToReq {
  to_req(Self) -> Req
}

///|
pub trait Cancelable: ToReq {
  cancel(Self) -> Unit raise Errno = _
}

///|
extern "c" fn uv_cancel(req : Req) -> Int = "moonbit_uv_cancel"

///|
impl Cancelable with cancel(self : Self) -> Unit raise Errno {
  let result = uv_cancel(self.to_req())
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
pub impl Cancelable for Fs
