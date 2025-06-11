///|
pub fn[T] backtrace(loc~ : SourceLoc = _, f : () -> T!Error) -> T!Error {
  try f() catch {
    SystemError(_, trace) as system_error => {
      trace.push(loc)
      raise system_error
    }
    error => raise error
  }
}

///|
priv enum ErrorInfo {
  Exists(&ToPath)
  IsDirectory(&ToPath)
  NotEmpty(&ToPath)
  NotFound(&ToPath)
  NotSupported(&ToPath)
} derive(ToJson(repr(ext_tagged)))

///|
priv type! SystemError {
  SystemError(ErrorInfo, Array[SourceLoc])
}

///|
fn SystemError::new(
  value : ErrorInfo,
  trace~ : Array[SourceLoc] = [],
  loc~ : SourceLoc = _
) -> SystemError {
  SystemError(value, [loc, ..trace])
}

///|
fn SystemError::exists(
  path : &ToPath,
  loc~ : SourceLoc = _,
  caller? : SourceLoc
) -> SystemError {
  let locs = [loc]
  if caller is Some(caller) {
    locs.push(caller)
  }
  SystemError(Exists(path), locs)
}

///|
fn SystemError::is_directory(
  path : &ToPath,
  loc~ : SourceLoc = _
) -> SystemError {
  SystemError(IsDirectory(path), [loc])
}

///|
fn SystemError::not_empty(path : &ToPath, loc~ : SourceLoc = _) -> SystemError {
  SystemError(NotEmpty(path), [loc])
}

///|
fn SystemError::not_found(path : &ToPath, loc~ : SourceLoc = _) -> SystemError {
  SystemError(NotFound(path), [loc])
}

///|
fn SystemError::not_supported(
  self : &ToPath,
  loc~ : SourceLoc = _
) -> SystemError {
  SystemError(NotSupported(self), [loc])
}

///|
let uv_ref : Ref[@uv.Loop?] = Ref::new(None)

///|
fn uv() -> @uv.Loop!@uv.Errno {
  if uv_ref.val is Some(uv) {
    return uv
  }
  let uv = @uv.Loop::new()
  uv_ref.val = Some(uv)
  return uv
}
