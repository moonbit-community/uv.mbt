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
let _args : FixedArray[String] = {
  let argv = moonbit_get_cli_args()
  FixedArray::makei(argv.length(), fn(i) {
    @encoding.decode_lossy(encoding=UTF8, argv[i])
  })
}

///|
#deprecated("Use `args` instead")
pub fn argv() -> Array[Bytes] {
  let argv = moonbit_get_cli_args()
  Array::makei(argv.length(), fn(i) { argv[i] })
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
pub fn args() -> Array[String] {
  Array::from_fixed_array(_args)
}
