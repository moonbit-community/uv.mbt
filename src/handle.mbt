///|
extern type Handle

///|
extern "c" fn uv_close(self : Handle, cb : (Handle) -> Unit) = "moonbit_uv_close"

///|
pub fn Handle::close(self : Handle, cb : (Handle) -> Unit) -> Unit {
  uv_close(self, cb)
}

///|
pub fn close[Handle : ToHandle](handle : Handle, cb : (Handle) -> Unit) -> Unit {
  handle.close(cb)
}

///|
extern "c" fn uv_is_closing(self : Handle) -> Bool = "moonbit_uv_is_closing"

///|
pub fn Handle::is_closing(self : Handle) -> Bool {
  uv_is_closing(self)
}

///|
pub fn is_closing[Handle : ToHandle](handle : Handle) -> Bool {
  handle.is_closing()
}

///|
pub trait ToHandle {
  to_handle(Self) -> Handle
  of_handle(Handle) -> Self
  close(Self, (Self) -> Unit) -> Unit = _
  is_closing(Self) -> Bool = _
}

///|
impl ToHandle with close(self, cb) {
  fn uv_cb(handle : Handle) {
    cb(ToHandle::of_handle(handle))
  }

  self.to_handle().close(uv_cb)
}

///|
impl ToHandle with is_closing(self) {
  return self.to_handle().is_closing()
}
