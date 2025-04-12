///|
type Tty

///|
pub impl ToHandle for Tty with to_handle(tty : Tty) -> Handle = "%identity"

///|
pub impl ToHandle for Tty with of_handle(handle : Handle) -> Tty = "%identity"

///|
pub impl ToStream for Tty with to_stream(tty : Tty) -> Stream = "%identity"

///|
pub impl ToStream for Tty with of_stream(stream : Stream) -> Tty = "%identity"

///|
extern "c" fn uv_tty_make() -> Tty = "moonbit_uv_tty_make"

///|
extern "c" fn uv_tty_init(loop_ : Loop, tty : Tty, fd : File) -> Int = "moonbit_uv_tty_init"

///|
pub fn Tty::new(self : Loop, fd : File) -> Tty!Errno {
  let tty = uv_tty_make()
  let result = uv_tty_init(self, tty, fd)
  if result < 0 {
    raise Errno::of_int(result)
  }
  tty
}

///|
pub(all) enum TtyMode {
  Normal
  Raw
  Io
  RawVT
}

///|
pub extern "c" fn tty_set_mode(tty : Tty, mode : TtyMode) -> Int = "moonbit_uv_tty_set_mode"

///|
pub extern "c" fn tty_reset_mode() -> Int = "moonbit_uv_tty_reset_mode"
