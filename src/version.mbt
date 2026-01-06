// Copyright 2026 International Digital Economy Academy
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
extern "c" fn uv_version_major() -> UInt = "moonbit_uv_version_major"

///|
extern "c" fn uv_version_minor() -> UInt = "moonbit_uv_version_minor"

///|
extern "c" fn uv_version_patch() -> UInt = "moonbit_uv_version_patch"

///|
extern "c" fn uv_version_suffix() -> @c.Pointer[Byte] = "moonbit_uv_version_suffix"

///|
extern "c" fn uv_version_string() -> @c.Pointer[Byte] = "moonbit_uv_version_string"

///|
struct Version {
  major : Int
  minor : Int
  patch : Int
  suffix : Bytes
}

///|
pub fn version() -> Version {
  return Version::{
    major: uv_version_major().reinterpret_as_int(),
    minor: uv_version_minor().reinterpret_as_int(),
    patch: uv_version_patch().reinterpret_as_int(),
    suffix: {
      let buf = @buffer.new()
      let ptr = uv_version_suffix()
      for i = 0; ptr[i] != 0; i = i + 1 {
        buf.write_byte(ptr[i])
      }
      buf.contents()
    },
  }
}

///|
pub fn Version::major(self : Version) -> Int {
  self.major
}

///|
pub fn Version::minor(self : Version) -> Int {
  self.minor
}

///|
pub fn Version::patch(self : Version) -> Int {
  self.patch
}

///|
pub fn Version::suffix(self : Version) -> Bytes {
  self.suffix
}

///|
pub fn Version::to_bytes(_ : Version) -> Bytes {
  let ptr = uv_version_string()
  let buffer = @buffer.new()
  for i = 0; ptr[i] != 0; i = i + 1 {
    buffer.write_byte(ptr[i])
  }
  buffer.contents()
}
