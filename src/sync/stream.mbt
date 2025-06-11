///|
type Iter[T] ((T) -> Unit!Error) -> Unit!Error

///|
pub fn[T] Iter::collect(self : Iter[T]) -> Array[T]!Error {
  let array = []
  (self._)(fn(item) { array.push(item) })
  array
}

///|
pub fn[T] Iter::filter(self : Iter[T], f : (T) -> Bool!Error) -> Iter[T] {
  fn(submit) { (self._)(fn(item) { if f(item) { submit(item) } }) }
}

///|
pub fn[T, U] Iter::bind(self : Iter[T], f : (T) -> U?!Error) -> Iter[U] {
  fn(submit) {
    (self._)(fn(item) { if f(item) is Some(value) { submit(value) } })
  }
}

///|
pub fn Iter::text(
  self : Iter[@bytes.View],
  encoding~ : @encoding.Encoding = UTF8
) -> String! {
  let decoder = @encoding.decoder(encoding)
  let builder = StringBuilder::new()
  (self._)(fn(bytes) { decoder.decode_to(bytes, builder, stream=true) })
  builder.to_string()
}

///|
pub fn Iter::decode(
  self : Iter[@bytes.View],
  encoding~ : @encoding.Encoding
) -> Iter[String] {
  let decoder = @encoding.decoder(encoding)
  let builder = StringBuilder::new()
  fn(submit) {
    (self._)(fn(bytes) {
      decoder.decode_to(bytes, builder, stream=true)
      let content = builder.to_string()
      submit(content)
      builder.reset()
    })
  }
}

///|
pub fn Iter::bytes(self : Iter[@bytes.View]) -> Bytes!Error {
  let buffer = @buffer.new()
  (self._)(buffer.write_bytesview(_))
  buffer.contents()
}

///|
pub fn[T] Iter::each(self : Iter[T], f : (T) -> Unit!Error) -> Unit!Error {
  (self._)(f)
}

///|
pub trait Readable {
  read(Self) -> Iter[@bytes.View]!Error
  read_text(Self, encoding~ : @encoding.Encoding) -> String!Error = _
  read_bytes(Self) -> Bytes!Error = _
}

///|
impl Readable with read_text(self : Self, encoding~ : @encoding.Encoding) {
  let decoder = @encoding.decoder(encoding)
  let builder = StringBuilder::new()
  (self.read()._)(decoder.decode_to(_, builder, stream=true))
  builder.to_string()
}

///|
impl Readable with read_bytes(self : Self) {
  let buffer = @buffer.new()
  (self.read()._)(buffer.write_bytesview(_))
  buffer.contents()
}

///|
pub trait Writable {
  write(Self, Iter[@bytes.View]) -> Unit!Error
  write_text(Self, @string.View, encoding~ : @encoding.Encoding) -> Unit!Error = _
  write_bytes(Self, @bytes.View) -> Unit!Error = _
}

///|
impl Writable with write_bytes(self : Self, bytes : @bytes.View) {
  self.write(fn(submit) { submit(bytes[:]) })
}

///|
impl Writable with write_text(
  self : Self,
  text : @string.View,
  encoding~ : @encoding.Encoding
) {
  let bytes = @encoding.encode(text, encoding~)
  self.write(fn(submit) { submit(bytes[:]) })
}
