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
fn moonbit_get_cli_args() -> FixedArray[Bytes] = "$moonbit.get_cli_args"

///|
let argv : FixedArray[Bytes] = moonbit_get_cli_args()

///|
#owned(argv)
extern "c" fn uv_setup_args(argv : FixedArray[Bytes]) = "moonbit_uv_setup_args"

///|
fn init {
  uv_setup_args(argv)
}

///|
/// Returns a _copy_ of command-line arguments passed to the program.
///
/// The arguments are copied to prevent accidental/intentional modification to
/// the original command-line arguments.
///
/// Example:
///
/// ```moonbit
/// println(@uv.args())
/// ```
pub fn args() -> FixedArray[Bytes] {
  argv
}

///|
#owned(buffer)
extern "c" fn uv_get_process_title(buffer : FixedArray[Byte]) -> Int = "moonbit_uv_get_process_title"

///|
pub fn get_process_title() -> Bytes raise {
  let mut buffer : FixedArray[Byte] = FixedArray::make(512, 0)
  let mut status = uv_get_process_title(buffer)
  while status == _ENOBUFS {
    buffer = FixedArray::make(buffer.length() * 2, 0)
    status = uv_get_process_title(buffer)
  }
  if status < 0 {
    raise Errno::of_int(status)
  }
  let len = for i in 0..<buffer.length() {
    if buffer[i] == 0 {
      break i
    }
  } else {
    buffer.length()
  }
  Bytes::from_array(buffer[:len])
}

///|
#owned(title)
extern "c" fn uv_set_process_title(title : Bytes) -> Int = "moonbit_uv_set_process_title"

///|
pub fn set_process_title(title : Bytes) -> Unit raise Errno {
  let status = uv_set_process_title(title)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
