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
  cb : (Signal, Signum) -> Unit,
  signum : Signum
) -> Unit!Errno {
  fn uv_cb(signal : Signal, signum : Int) {
    let signum = Signum::of_int(signum)
    cb(signal, signum)
  }

  let signum = signum.to_int()
  guard signum is Some(signum) else { raise Errno(EINVAL) }
  let status = uv_signal_start(self, uv_cb, signum)
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

///|
extern "c" fn uv_SIGHUP() -> Int = "moonbit_uv_SIGHUP"

///|
extern "c" fn uv_SIGINT() -> Int = "moonbit_uv_SIGINT"

///|
extern "c" fn uv_SIGQUIT() -> Int = "moonbit_uv_SIGQUIT"

///|
extern "c" fn uv_SIGABRT() -> Int = "moonbit_uv_SIGABRT"

///|
extern "c" fn uv_SIGTERM() -> Int = "moonbit_uv_SIGTERM"

///|
extern "c" fn uv_SIGWINCH() -> Int = "moonbit_uv_SIGWINCH"

///|
pub enum Signum {
  SIGHUP
  SIGINT
  SIGQUIT
  SIGABRT
  SIGTERM
  SIGWINCH
} derive(Eq, Hash)

///|
let signum_to_int : Map[Signum, Int] = {
  let map = Map::new()
  map[SIGHUP] = uv_SIGHUP()
  map[SIGINT] = uv_SIGINT()
  map[SIGQUIT] = uv_SIGQUIT()
  map[SIGABRT] = uv_SIGABRT()
  map[SIGTERM] = uv_SIGTERM()
  map[SIGWINCH] = uv_SIGWINCH()
  map
}

///|
let signum_of_int : Map[Int, Signum] = {
  let map = Map::new()
  for signum, int in signum_to_int {
    map[int] = signum
  }
  map
}

///|
fn Signum::to_int(self : Signum) -> Int? {
  signum_to_int[self]
}

///|
fn Signum::of_int(self : Int) -> Signum {
  signum_of_int[self].unwrap()
}
