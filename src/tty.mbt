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
extern "c" fn uv_tty_init(uv : Loop, tty : Tty, fd : Int) -> Int = "moonbit_uv_tty_init"

///|
pub fn Tty::new(self : Loop, file : File) -> Tty raise Errno {
  let tty = uv_tty_make()
  let result = uv_tty_init(self, tty, file._)
  if result < 0 {
    raise Errno::of_int(result)
  }
  tty
}

///|
enum TtyMode {
  Normal
  Raw
  Io
  RawVT
}

///|
pub fn TtyMode::normal() -> TtyMode {
  TtyMode::Normal
}

///|
pub fn TtyMode::raw() -> TtyMode {
  TtyMode::Raw
}

///|
pub fn TtyMode::io() -> TtyMode {
  TtyMode::Io
}

///|
pub fn TtyMode::raw_vt() -> TtyMode {
  TtyMode::RawVT
}

///|
extern "c" fn uv_tty_set_mode(tty : Tty, mode : TtyMode) -> Int = "moonbit_uv_tty_set_mode"

///|
pub fn Tty::set_mode(self : Tty, mode : TtyMode) -> Unit raise Errno {
  let result = uv_tty_set_mode(self, mode)
  if result < 0 {
    raise Errno::of_int(result)
  }
}

///|
extern "c" fn uv_tty_reset_mode() -> Int = "moonbit_uv_tty_reset_mode"

///|
pub fn Tty::reset_mode() -> Unit raise Errno {
  let result = uv_tty_reset_mode()
  if result < 0 {
    raise Errno::of_int(result)
  }
}
