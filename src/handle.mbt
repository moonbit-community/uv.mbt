///|
extern type Handle

///|
extern "c" fn uv_close(handle : Handle, cb : (Handle) -> Unit) = "moonbit_uv_close"

///|
pub fn close(self : Handle, cb : (Handle) -> Unit) -> Unit {
  uv_close(self, cb)
}

///|
extern "c" fn uv_is_closing(handle : Handle) -> Bool = "moonbit_uv_is_closing"

///|
pub fn is_closing(self : Handle) -> Bool {
  uv_is_closing(self)
}

///|
pub extern "c" fn handle_get_loop(handle : Handle) -> Loop = "moonbit_uv_handle_get_loop"

///|
pub trait ToHandle {
  to_handle(Self) -> Handle
  of_handle(Handle) -> Self
  close(Self, (Self) -> Unit) -> Unit
  is_closing(Self) -> Bool
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
