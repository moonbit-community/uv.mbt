type Tty

pub fn Tty::to_stream(tty : Tty) -> Stream = "%identity"

pub extern "c" fn tty_alloc() -> Tty = "moonbit_uv_tty_alloc"

pub extern "c" fn tty_init(loop_ : Loop, tty : Tty, fd : File) -> Int = "moonbit_uv_tty_init"

pub(all) enum TtyMode {
  Normal
  Raw
  Io
  RawVT
}

pub extern "c" fn tty_set_mode(tty : Tty, mode : TtyMode) -> Int = "moonbit_uv_tty_set_mode"

pub extern "c" fn tty_reset_mode() -> Int = "moonbit_uv_tty_reset_mode"
