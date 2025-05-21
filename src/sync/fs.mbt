///|
type ErrorIter[T] ((T) -> Unit!Error) -> Unit!Error

///|
pub fn ErrorIter::each[T](
  self : ErrorIter[T],
  f : (T) -> Unit!Error
) -> Unit!Error {
  (self._)!(fn(item) { f!(item) })
}

///|
type! IterBreak

///|
pub fn Path::read(self : Path) -> Iter[Result[@bytes.View, Error]] {
  Iter::new(fn(yield_) {
    try {
      let mut result = IterContinue
      @async.start!(fn() {
        try {
          self._
          .read!()
          .each!(fn(bytes) {
            match yield_(Ok(bytes)) {
              IterEnd => raise IterBreak
              IterContinue => ()
            }
          })
        } catch {
          IterBreak => result = IterEnd
          error =>
            match yield_(Err(error)) {
              IterEnd => raise IterBreak
              IterContinue => ()
            }
        }
      })
      result
    } catch {
      e => yield_(Err(e))
    }
  })
}
