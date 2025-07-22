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
extern "c" fn uv_utf16_length_as_wtf8(utf16 : String) -> UInt64 = "moonbit_uv_utf16_length_as_wtf8"

///|
extern "c" fn uv_utf16_to_wtf8(utf16 : String, wtf8 : Bytes) -> Int = "moonbit_uv_utf16_to_wtf8"

///|
pub fn string_to_wtf8(utf16 : String) -> Bytes {
  let length = uv_utf16_length_as_wtf8(utf16).to_int()
  let wtf8 = Bytes::make(length, 0)
  let result = uv_utf16_to_wtf8(utf16, wtf8)
  guard result == 0
  wtf8
}

///|
extern "c" fn uv_wtf8_length_as_utf16(wtf8 : Bytes) -> Int64 = "moonbit_uv_wtf8_length_as_utf16"

///|
extern "c" fn uv_wtf8_to_utf16(wtf8 : Bytes, utf16 : String) = "moonbit_uv_wtf8_to_utf16"

///|
pub fn wtf8_to_string(wtf8 : Bytes) -> String {
  let length = uv_wtf8_length_as_utf16(wtf8).to_int()
  let utf16 = String::make(length, '\u{00}')
  uv_wtf8_to_utf16(wtf8, utf16)
  utf16
}
