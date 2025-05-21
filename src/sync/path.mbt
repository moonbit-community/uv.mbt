///|
type Path @async.Path

///|
pub fn path(path : String) -> Path! {
  @async.path!(path)
}
