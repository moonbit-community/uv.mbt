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
pub trait Readable {
  read(Self) -> Iter[@bytes.View] raise Error
  read_text(Self, encoding~ : @encoding.Encoding) -> String raise Error = _
  read_bytes(Self) -> Bytes raise Error = _
}

///|
impl Readable with read_text(self : Self, encoding~ : @encoding.Encoding) {
  let decoder = @encoding.decoder(encoding)
  let builder = StringBuilder::new()
  for bytes in self.read() {
    decoder.decode_to(bytes, builder, stream=true)
  }
  builder.to_string()
}

///|
impl Readable with read_bytes(self : Self) {
  let buffer = @buffer.new()
  for bytes in self.read() {
    buffer.write_bytesview(bytes)
  }
  buffer.contents()
}

///|
pub trait Writable {
  write(Self, Iter[@bytes.View]) -> Unit raise Error
  write_text(Self, @string.View, encoding~ : @encoding.Encoding) -> Unit raise Error = _
  write_bytes(Self, @bytes.View) -> Unit raise Error = _
}

///|
impl Writable with write_bytes(self : Self, bytes : @bytes.View) {
  self.write([bytes[:]].iter())
}

///|
impl Writable with write_text(
  self : Self,
  text : @string.View,
  encoding~ : @encoding.Encoding,
) {
  let bytes = @encoding.encode(text, encoding~)
  self.write([bytes[:]].iter())
}
