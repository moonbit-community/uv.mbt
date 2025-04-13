///|
type Signal

///|
extern "c" fn uv_signal_make() -> Signal = "moonbit_uv_signal_make"

///|
extern "c" fn uv_signal_init(self : Loop, signal : Signal) -> Int = "moonbit_uv_signal_init"

///|
pub fn Signal::new(self : Loop) -> Signal!Errno {
  let signal = uv_signal_make()
  let status = uv_signal_init(self, signal)
  if status < 0 {
    raise Errno::of_int(status)
  }
  signal
}

///|
extern "c" fn uv_signal_start(
  signal : Signal,
  cb : (Signal, Int) -> Unit,
  signum : Int
) -> Int = "moonbit_uv_signal_start"

///|
pub fn Signal::start(
  self : Signal,
  cb : (Signal, Int) -> Unit,
  signum : Int
) -> Unit!Errno {
  let status = uv_signal_start(self, cb, signum)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_signal_stop(signal : Signal) -> Int = "moonbit_uv_signal_stop"

///|
pub fn Signal::stop(self : Signal) -> Unit!Errno {
  let status = uv_signal_stop(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
