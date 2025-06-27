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
type Iter[T] async (async (T) -> Unit raise) -> Unit raise

///|
pub async fn[T] Iter::collect(self : Iter[T]) -> Array[T] raise {
  let array = []
  self.inner()(fn(item) { array.push(item) })
  array
}

///|
pub async fn[T] Iter::filter(
  self : Iter[T],
  f : async (T) -> Bool raise?
) -> Iter[T] {
  fn(yield_) { self.inner()(fn(item) { if f(item) { yield_(item) } }) }
}

///|
pub async fn[T, U] Iter::bind(
  self : Iter[T],
  f : async (T) -> U? raise?
) -> Iter[U] {
  fn(yield_) {
    self.inner()(fn(item) {
      let result = f(item)
      if result is Some(value) {
        yield_(value)
      }
    })
  }
}

///|
pub async fn Iter::text(
  self : Iter[@bytes.View],
  encoding~ : @encoding.Encoding = UTF8
) -> String raise {
  let decoder = @encoding.decoder(encoding)
  let builder = StringBuilder::new()
  self.inner()(fn(bytes) { decoder.decode_to(bytes, builder, stream=true) })
  builder.to_string()
}

///|
pub async fn Iter::decode(
  self : Iter[@bytes.View],
  encoding~ : @encoding.Encoding
) -> Iter[String] {
  let decoder = @encoding.decoder(encoding)
  let builder = StringBuilder::new()
  fn(yield_) {
    self.inner()(fn(bytes) {
      decoder.decode_to(bytes, builder, stream=true)
      let content = builder.to_string()
      yield_(content)
      builder.reset()
    })
  }
}

///|
pub async fn Iter::bytes(self : Iter[@bytes.View]) -> Bytes raise {
  let buffer = @buffer.new()
  self.inner()(fn(bytes) { buffer.write_bytesview(bytes) })
  buffer.contents()
}

///|
pub async fn[T] Iter::each(
  self : Iter[T],
  f : async (T) -> Unit raise
) -> Unit raise {
  self.inner()(fn(item) { f(item) })
}

///|
pub trait Readable {
  async read(Self) -> Iter[@bytes.View] raise Error
  async read_text(Self, encoding~ : @encoding.Encoding) -> String raise Error = _
  async read_bytes(Self) -> Bytes raise Error = _
}

///|
impl Readable with read_text(self : Self, encoding~ : @encoding.Encoding) {
  let decoder = @encoding.decoder(encoding)
  let builder = StringBuilder::new()
  self.read().inner()(fn(bytes) {
    decoder.decode_to(bytes, builder, stream=true)
  })
  builder.to_string()
}

///|
impl Readable with read_bytes(self : Self) {
  let buffer = @buffer.new()
  self.read().inner()(fn(bytes) { buffer.write_bytesview(bytes) })
  buffer.contents()
}

///|
pub trait Writable {
  async write(Self, Iter[@bytes.View]) -> Unit raise Error
  async write_text(Self, @string.View, encoding~ : @encoding.Encoding) -> Unit raise Error = _
  async write_bytes(Self, @bytes.View) -> Unit raise Error = _
}

///|
impl Writable with write_bytes(self : Self, bytes : @bytes.View) {
  self.write(fn(yield_) { yield_(bytes[:]) })
}

///|
impl Writable with write_text(
  self : Self,
  text : @string.View,
  encoding~ : @encoding.Encoding
) {
  let bytes = @encoding.encode(text, encoding~)
  self.write(fn(yield_) { yield_(bytes[:]) })
}

///|
impl Readable for @uv.Stream with read(self : @uv.Stream) {
  fn(yield_) {
    async_suspend_with_error(fn(resolve, reject) {
      self.read_start(
        fn(_, _) { Bytes::make(256, 0)[:] },
        fn(_, count, bytes) {
          async_run(fn() { yield_(bytes[:count]) catch { e => reject(e) } })
        },
        fn(_, e) {
          let _ = try? self.read_stop()
          self.close(fn(_) {
            if e is Errno(EOF) {
              resolve(())
            } else {
              reject(e)
            }
          })
        },
      ) catch {
        e => self.close(fn(_) { reject(e) })
      }
    })
  }
}

///|
impl Writable for @uv.Stream with write(
  self : @uv.Stream,
  bytes : Iter[@bytes.View]
) -> Unit raise Error {
  bytes.each(fn(bytes) {
    async_suspend_with_error(fn(resolve, reject) {
      try
        self.write([bytes], fn() { resolve(()) }, fn(e) { reject(e) })
        |> ignore()
      catch {
        e => reject(e)
      }
    })
  })
}

///|
pub impl Readable for @bytes.View with read(self : @bytes.View) {
  fn(yield_) { yield_(self) }
}

///|
pub impl Readable for Bytes with read(self : Bytes) {
  fn(yield_) { yield_(self[:]) }
}

///|
pub impl Writable for @buffer.T with write(
  self : @buffer.T,
  bytes : Iter[@bytes.View]
) {
  bytes.each(fn(bytes) { self.write_bytesview(bytes) })
}
