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
  let result = uv_tty_init(self, tty, file.inner())
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

///|
extern "c" fn uv_tty_get_winsize(
  tty : Tty,
  width : FixedArray[Int],
  height : FixedArray[Int],
) -> Int = "moonbit_uv_tty_get_winsize"

///|
pub fn Tty::get_winsize(self : Tty) -> (Int, Int) raise Errno {
  let width : FixedArray[Int] = [0]
  let height : FixedArray[Int] = [0]
  let result = uv_tty_get_winsize(self, width, height)
  if result < 0 {
    raise Errno::of_int(result)
  }
  (width[0], height[0])
}
