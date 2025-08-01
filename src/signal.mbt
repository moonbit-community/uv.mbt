// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
type Signal

///|
extern "c" fn uv_signal_make() -> Signal = "moonbit_uv_signal_make"

///|
extern "c" fn uv_signal_init(uv : Loop, signal : Signal) -> Int = "moonbit_uv_signal_init"

///|
pub fn Signal::new(self : Loop) -> Signal raise Errno {
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
  signum : Int,
) -> Int = "moonbit_uv_signal_start"

///|
pub fn Signal::start(
  self : Signal,
  cb : (Signal, Signum) -> Unit,
  signum : Signum,
) -> Unit raise Errno {
  fn uv_cb(signal : Signal, signum : Int) {
    cb(signal, signum)
  }

  let status = uv_signal_start(self, uv_cb, signum.inner())
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_signal_stop(signal : Signal) -> Int = "moonbit_uv_signal_stop"

///|
pub fn Signal::stop(self : Signal) -> Unit raise Errno {
  let status = uv_signal_stop(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_SIGHUP() -> Int = "moonbit_uv_SIGHUP"

///|
let _SIGHUP : Int = uv_SIGHUP()

///|
extern "c" fn uv_SIGINT() -> Int = "moonbit_uv_SIGINT"

///|
let _SIGINT : Int = uv_SIGINT()

///|
extern "c" fn uv_SIGQUIT() -> Int = "moonbit_uv_SIGQUIT"

///|
let _SIGQUIT : Int = uv_SIGQUIT()

///|
extern "c" fn uv_SIGABRT() -> Int = "moonbit_uv_SIGABRT"

///|
let _SIGABRT : Int = uv_SIGABRT()

///|
extern "c" fn uv_SIGTERM() -> Int = "moonbit_uv_SIGTERM"

///|
let _SIGTERM : Int = uv_SIGTERM()

///|
extern "c" fn uv_SIGWINCH() -> Int = "moonbit_uv_SIGWINCH"

///|
let _SIGWINCH : Int = uv_SIGWINCH()

///|
extern "c" fn uv_SIGPIPE() -> Int = "moonbit_uv_SIGPIPE"

///|
let _SIGPIPE : Int = uv_SIGPIPE()

///|
extern "c" fn uv_SIGPROF() -> Int = "moonbit_uv_SIGPROF"

///|
let _SIGPROF : Int = uv_SIGPROF()

///|
type Signum Int

///|
pub fn Signum::sighup() -> Signum {
  _SIGHUP
}

///|
pub fn Signum::sigint() -> Signum {
  _SIGINT
}

///|
pub fn Signum::sigquit() -> Signum {
  _SIGQUIT
}

///|
pub fn Signum::sigabrt() -> Signum {
  _SIGABRT
}

///|
pub fn Signum::sigterm() -> Signum {
  _SIGTERM
}

///|
pub fn Signum::sigwinch() -> Signum {
  _SIGWINCH
}

///|
pub fn Signum::sigpipe() -> Signum raise Errno {
  if _SIGPIPE == -1 {
    raise ENOSYS
  }
  _SIGPIPE
}

///|
pub fn Signum::sigprof() -> Signum raise Errno {
  if _SIGPROF == -1 {
    raise ENOSYS
  }
  _SIGPROF
}
