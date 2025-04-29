///|
priv struct WindowsPath {
  parts : ArrayView[@string.View]
}

///|
priv trait ToWindowsPath {
  to_windows_path(Self) -> WindowsPath
}

///|
impl ToWindowsPath for @string.View with to_windows_path(self : @string.View) -> WindowsPath {
  enum UncState {
    Zero
    One
  }
  fn make_part(char : Char) -> StringBuilder {
    let part = StringBuilder::new()
    part.write_char(char)
    return part
  }

  let parts : Array[@string.View] = []
  path~: loop None, self {
    None, [drive, ':', '/' | '\\', .. path] => {
      parts.push("\{drive}:\\")
      skip~: loop path {
        ['/' | '\\', .. path] => continue skip~ path
        [char, .. path] => continue path~ Some(make_part(char)), path
        [] => break path~ { parts, }
      }
    }
    None, [drive, ':', char, .. path] => {
      parts.push("\{drive}:")
      continue path~ Some(make_part(char)), path
    }
    None, [drive, ':'] => {
      parts.push("\{drive}:")
      break path~ { parts, }
    }
    None, [.. "//", .. path] | [.. "\\\\", .. path] => {
      let unc = StringBuilder::new()
      unc.write_string("\\\\")
      unc~: loop Zero, path {
        Zero, ['/' | '\\', .. path] => {
          unc.write_char('\\')
          continue unc~ One, path
        }
        One, ['/' | '\\', char, .. path] => {
          unc.write_char('\\')
          parts.push(unc.to_string())
          continue path~ Some(make_part(char)), path
        }
        One, ['/' | '\\'] => {
          unc.write_char('\\')
          parts.push(unc.to_string())
          break path~ { parts, }
        }
        Zero, [char, .. path] => {
          unc.write_char(char)
          continue unc~ Zero, path
        }
        One, [char, .. path] => {
          unc.write_char(char)
          continue unc~ One, path
        }
        Zero, [] => {
          parts.push(unc.to_string())
          break path~ { parts, }
        }
        One, [] => {
          unc.write_char('\\')
          parts.push(unc.to_string())
          break path~ { parts, }
        }
      }
    }
    None, ['/' | '\\', char, .. path] => {
      parts.push("\\")
      continue path~ Some(make_part(char)), path
    }
    None, [char, .. path] => {
      let part = make_part(char)
      continue path~ Some(part), path
    }
    None, [] => break path~ { parts, }
    Some(part), ['/' | '\\', .. path] => {
      parts.push(part.to_string())
      skip~: loop path {
        ['/' | '\\', .. path] => continue skip~ path
        [char, .. path] => continue path~ Some(make_part(char)), path
        [] => break path~ { parts, }
      }
    }
    Some(part), [char, .. path] => {
      part.write_char(char)
      continue path~ Some(part), path
    }
    Some(part), [] => {
      parts.push(part.to_string())
      break path~ { parts, }
    }
  }
}

///|
impl ToWindowsPath for String with to_windows_path(self : String) -> WindowsPath {
  ToWindowsPath::to_windows_path(self.view())
}

///|
impl[T : ToWindowsPath] ToWindowsPath for Array[T] with to_windows_path(
  self : Array[T]
) -> WindowsPath {
  let mut path : WindowsPath = WindowsPath::{ parts: [] }
  for part in self {
    path = path / part.to_windows_path()
  }
  path
}

///|
test "to_windows_path" {
  @json.inspect!(ToWindowsPath::to_windows_path("C:\\Windows").parts, content=[
    "C:\\", "Windows",
  ])
  @json.inspect!(ToWindowsPath::to_windows_path("C:/Windows").parts, content=[
    "C:\\", "Windows",
  ])
  @json.inspect!(ToWindowsPath::to_windows_path("C:/Windows/").parts, content=[
    "C:\\", "Windows",
  ])
  @json.inspect!(ToWindowsPath::to_windows_path("C:\\Windows\\").parts, content=[
    "C:\\", "Windows",
  ])
  @json.inspect!(ToWindowsPath::to_windows_path("C:Windows").parts, content=[
    "C:", "Windows",
  ])
  @json.inspect!(ToWindowsPath::to_windows_path("C:Windows/").parts, content=[
    "C:", "Windows",
  ])
  @json.inspect!(ToWindowsPath::to_windows_path("//unc/share/a/b").parts, content=[
    "\\\\unc\\share\\", "a", "b",
  ])
  @json.inspect!(ToWindowsPath::to_windows_path("\\\\unc\\share\\a\\b").parts, content=[
    "\\\\unc\\share\\", "a", "b",
  ])
}

///|
priv struct PosixPath {
  parts : ArrayView[@string.View]
}

///|
priv trait ToPosixPath {
  to_posix_path(Self) -> PosixPath
}

///|
impl ToPosixPath for @string.View with to_posix_path(self : @string.View) -> PosixPath {
  fn make_part(char : Char) -> StringBuilder {
    let part = StringBuilder::new()
    part.write_char(char)
    return part
  }

  let parts : Array[@string.View] = []
  path~: loop None, self {
    None, [.. "///", .. path] => {
      parts.push("/")
      skip~: loop path {
        ['/', .. path] => continue skip~ path
        [char, .. path] => continue path~ Some(make_part(char)), path
        [] => break path~ { parts, }
      }
    }
    None, [.. "//", char, .. path] => {
      parts.push("//")
      continue path~ Some(make_part(char)), path
    }
    None, [.. "/", char, .. path] => {
      parts.push("/")
      continue path~ Some(make_part(char)), path
    }
    None, [char, .. path] => {
      let part = make_part(char)
      continue path~ Some(part), path
    }
    None, [] => break path~ { parts, }
    Some(part), ['/', .. path] => {
      parts.push(part.to_string())
      skip~: loop path {
        ['/', .. path] => continue skip~ path
        [char, .. path] => continue path~ Some(make_part(char)), path
        [] => break path~ { parts, }
      }
    }
    Some(part), [char, .. path] => {
      part.write_char(char)
      continue path~ Some(part), path
    }
    Some(part), [] => {
      parts.push(part.to_string())
      break path~ { parts, }
    }
  }
}

///|
impl ToPosixPath for String with to_posix_path(self : String) -> PosixPath {
  ToPosixPath::to_posix_path(self.view())
}

///|
impl[T : ToPosixPath] ToPosixPath for Array[T] with to_posix_path(
  self : Array[T]
) -> PosixPath {
  let mut path : PosixPath = PosixPath::{ parts: [] }
  for part in self {
    path = path / part.to_posix_path()
  }
  path
}

///|
test "to_posix_path" {
  @json.inspect!(ToPosixPath::to_posix_path("//usr//bin//").parts, content=[
    "//", "usr", "bin",
  ])
  @json.inspect!(ToPosixPath::to_posix_path("/usr/bin").parts, content=[
    "/", "usr", "bin",
  ])
  @json.inspect!(ToPosixPath::to_posix_path("/usr/bin/").parts, content=[
    "/", "usr", "bin",
  ])
  @json.inspect!(ToPosixPath::to_posix_path("usr/bin").parts, content=[
    "usr", "bin",
  ])
  @json.inspect!(ToPosixPath::to_posix_path("usr/bin/").parts, content=[
    "usr", "bin",
  ])
  @json.inspect!(ToPosixPath::to_posix_path("usr//bin").parts, content=[
    "usr", "bin",
  ])
  @json.inspect!(ToPosixPath::to_posix_path("C:\\Windows").parts, content=[
    "C:\\Windows",
  ])
}

///|
enum Path {
  WindowsPath(WindowsPath)
  PosixPath(PosixPath)
}

///|
impl Div for PosixPath with op_div(self : PosixPath, other : PosixPath) -> PosixPath {
  return PosixPath::{ parts: [..self.parts, ..other.parts] }
}

///|
impl @uv.ToNtbs for PosixPath with to_ntbs(self : PosixPath) -> Bytes {
  let buffer = @buffer.new()
  for i, part in self.parts {
    if i > 0 {
      buffer.write_byte('/')
    }
    @encoding.encode_to(part, buffer, encoding=UTF8)
  }
  buffer.write_byte(0)
  buffer.contents()
}

///|
fn PosixPath::parent(self : PosixPath) -> PosixPath {
  match self.parts {
    [.. parts, _] => PosixPath::{ parts, }
    [] => PosixPath::{ parts: [] }
  }
}

///|
impl Div for WindowsPath with op_div(self : WindowsPath, other : WindowsPath) -> WindowsPath {
  return WindowsPath::{ parts: [..self.parts, ..other.parts] }
}

///|
impl @uv.ToNtbs for WindowsPath with to_ntbs(self : WindowsPath) -> Bytes {
  let buffer = @buffer.new()
  for part in self.parts {
    buffer.write_stringview(part)
    buffer.write_char('\\')
  }
  buffer.contents()
}

///|
fn WindowsPath::parent(self : WindowsPath) -> WindowsPath {
  match self.parts {
    [[_, ':', ..],  ..,  _] as parts =>
      WindowsPath::{ parts: parts[:parts.length() - 1] }
    [['\\', ..],  ..,  _] as parts =>
      WindowsPath::{ parts: parts[:parts.length() - 1] }
    [.. parts, _] => WindowsPath::{ parts, }
    [] => WindowsPath::{ parts: [] }
  }
}

///|
fn Path::parent(self : Path) -> Path {
  match self {
    WindowsPath(w) => WindowsPath(w.parent())
    PosixPath(p) => PosixPath(p.parent())
  }
}

///|
impl Div for Path with op_div(self : Path, other : Path) -> Path {
  match (self, other) {
    (WindowsPath(self), WindowsPath(other)) => WindowsPath(self / other)
    (PosixPath(self), PosixPath(other)) => PosixPath(self / other)
    _ => abort("Cannot combine Windows and Posix paths")
  }
}

///|
pub impl @uv.ToNtbs for Path with to_ntbs(self : Path) -> Bytes {
  match self {
    WindowsPath(w) => w.to_ntbs()
    PosixPath(p) => p.to_ntbs()
  }
}

///|
trait ToPath {
  to_path(Self) -> Path!PathError
}

///|
type! PathError {
  Errno(@uv.Errno)
}

///|
pub impl ToPath for @string.View with to_path(self : @string.View) -> Path!PathError {
  let utsname = try {
    @uv.os_uname!()
  } catch {
    e => raise PathError::Errno(e)
  }
  if utsname.sysname() == "Windows" {
    return WindowsPath(ToWindowsPath::to_windows_path(self))
  } else {
    return PosixPath(ToPosixPath::to_posix_path(self))
  }
}

///|
pub impl ToPath for String with to_path(self : String) -> Path!PathError {
  ToPath::to_path!(self.view())
}

///|
pub impl[T : ToPath] ToPath for Array[T] with to_path(self : Array[T]) -> Path!PathError {
  let utsname = try {
    @uv.os_uname!()
  } catch {
    e => raise PathError::Errno(e)
  }
  let mut path : Path = if utsname.sysname() == "Windows" {
    WindowsPath(WindowsPath::{ parts: [] })
  } else {
    PosixPath(PosixPath::{ parts: [] })
  }
  for part in self {
    path = path / part.to_path!()
  }
  return path
}

///|
pub fn path[Input : ToPath](path : Input) -> Path!PathError {
  path.to_path!()
}

///|
impl Eq for WindowsPath with op_equal(self : WindowsPath, other : WindowsPath) -> Bool {
  self.parts == other.parts
}

///|
impl Eq for PosixPath with op_equal(self : PosixPath, other : PosixPath) -> Bool {
  self.parts == other.parts
}

///|
pub impl Eq for Path with op_equal(self : Path, other : Path) -> Bool {
  match (self, other) {
    (WindowsPath(self), WindowsPath(other)) => self == other
    (PosixPath(self), PosixPath(other)) => self == other
    _ => false
  }
}

///|
impl Show for WindowsPath with output(self : WindowsPath, logger : &Logger) -> Unit {
  for i, part in self.parts {
    if i > 0 {
      logger.write_char('\\')
    }
    logger.write_object(part)
  }
}

///|
impl Show for PosixPath with output(self : PosixPath, logger : &Logger) -> Unit {
  for i, part in self.parts {
    if i > 0 {
      logger.write_char('/')
    }
    logger.write_object(part)
  }
}

///|
pub impl Show for Path with output(self : Path, logger : &Logger) -> Unit {
  match self {
    WindowsPath(w) => w.output(logger)
    PosixPath(p) => p.output(logger)
  }
}
