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
extern "c" fn uv_version() -> UInt = "moonbit_uv_version"

///|
extern "c" fn uv_version_string() -> @c.Pointer[Byte] = "moonbit_uv_version_string"

///|
struct Version(UInt)

///|
pub fn version() -> Version {
  uv_version()
}

///|
pub fn Version::major(self : Version) -> Int {
  ((self.inner() >> 16) & 0xFF).reinterpret_as_int()
}

///|
pub fn Version::minor(self : Version) -> Int {
  ((self.inner() >> 8) & 0xFF).reinterpret_as_int()
}

///|
pub fn Version::patch(self : Version) -> Int {
  (self.inner() & 0xFF).reinterpret_as_int()
}

///|
pub fn Version::string(_ : Version) -> Bytes {
  let ptr = uv_version_string()
  let buffer = @buffer.new()
  for i = 0; ptr[i] != 0; i = i + 1 {
    buffer.write_byte(ptr[i])
  }
  buffer.contents()
}
