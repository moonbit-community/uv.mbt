///|
type Iter[T] ((T) -> Unit!Error) -> Unit!Error

///|
pub fn[T] Iter::each(self : Iter[T], f : (T) -> Unit!Error) -> Unit!Error {
  (self._)!(fn(item) { f!(item) })
}

///|
pub fn Path::read(self : Path) -> Iter[@bytes.View] {
  fn(yield_) {
    @async.start!(fn() { self._.read!().each!(fn(bytes) { yield_!(bytes) }) })
  }
}

///|
pub fn Path::read_text(self : Path) -> String!Error {
  @async.start!(fn() { self._.read_text!() })
}

///|
pub fn Path::read_bytes(self : Path) -> Bytes!Error {
  @async.start!(fn() { self._.read_bytes!() })
}
