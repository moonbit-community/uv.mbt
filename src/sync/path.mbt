///|
priv enum Flavor {
  Windows
  Posix
} derive(Show, Eq, Compare, Hash)

///|
impl ToJson for Flavor with to_json(self : Flavor) -> Json {
  return match self {
    Windows => "windows"
    Posix => "posix"
  }
}

///|
struct Path {
  flavor : Flavor
  drive : @string.View
  root : @string.View
  anchor : @string.View
  parts : ArrayView[@string.View]
} derive(Eq, Hash, ToJson)

///|
pub fn Path::parts(self : Path) -> ArrayView[@string.View] {
  self.parts
}

///|
pub fn Path::drive(self : Path) -> @string.View {
  self.drive
}

///|
pub fn Path::root(self : Path) -> @string.View {
  self.root
}

///|
pub fn Path::anchor(self : Path) -> @string.View {
  self.anchor
}

///|
pub impl Compare for Path with compare(self : Path, other : Path) -> Int {
  if self.flavor != other.flavor {
    return self.flavor.compare(other.flavor)
  }
  return self.parts.compare(other.parts)
}

///|
pub fn Path::parse_posix(path : @string.View) -> Path {
  let root = StringBuilder::new()
  fn make_path(path : Array[@string.View]) -> Path {
    let root = root.to_string()
    return Path::{ flavor: Posix, drive: "", root, anchor: root, parts: path }
  }

  let parts : Array[@string.View] = []
  let part = StringBuilder::new()
  let path = match path {
    [.. "///", .. path] => {
      root.write_char('/')
      parts.push("/")
      skip~: loop path {
        ['/', .. path] => continue skip~ path
        [char, .. path] => {
          part.write_char(char)
          path
        }
        [] => return make_path(parts)
      }
    }
    [.. "//", .. path] => {
      root.write_string("//")
      parts.push("//")
      path
    }
    ['/', .. path] => {
      root.write_char('/')
      parts.push("/")
      path
    }
    [.. path] => path
  }
  fn push_part(part : String) {
    if part is ("" | ".") {
      return
    }
    parts.push(part)
  }

  path~: loop path {
    ['/', .. path] => {
      push_part(part.to_string())
      skip~: loop path {
        ['/', .. path] => continue skip~ path
        [char, .. path] => {
          part.reset()
          part.write_char(char)
          continue path~ path
        }
        [] => break path~ make_path(parts)
      }
    }
    [char, .. path] => {
      part.write_char(char)
      continue path~ path
    }
    [] => {
      push_part(part.to_string())
      return make_path(parts)
    }
  }
}

///|
test "posix_path/root" {
  @json.inspect(Path::parse_posix("/"), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/"],
  })
  @json.inspect(Path::parse_posix("//"), content={
    "flavor": "posix",
    "drive": "",
    "root": "//",
    "anchor": "//",
    "parts": ["//"],
  })
  @json.inspect(Path::parse_posix("///"), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/"],
  })
  @json.inspect(Path::parse_posix("//usr//bin//"), content={
    "flavor": "posix",
    "drive": "",
    "root": "//",
    "anchor": "//",
    "parts": ["//", "usr", "bin"],
  })
  @json.inspect(Path::parse_posix("////usr"), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/", "usr"],
  })
  @json.inspect(Path::parse_posix("/usr/bin"), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/", "usr", "bin"],
  })
}

///|
pub fn[ToPosixPath : ToPosixPath] Path::posix(path : ToPosixPath) -> Path {
  path.to_posix_path()
}

///|
test "posix_path" {
  @json.inspect(Path::parse_posix("usr/bin"), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
  @json.inspect(Path::parse_posix("usr/bin/"), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
  @json.inspect(Path::parse_posix("usr//bin"), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
  @json.inspect(Path::parse_posix("C:\\Windows"), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["C:\\Windows"],
  })
}

///|
test "posix_path/empty" {
  @json.inspect(Path::parse_posix(""), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": [],
  })
}

///|
test "posix_path/collapse_slashes" {
  @json.inspect(Path::parse_posix("usr/////bin"), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
  @json.inspect(Path::parse_posix("usr//bin//"), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
  @json.inspect(Path::parse_posix("usr///bin//"), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
}

///|
test "posix_path/collapse_dots" {
  @json.inspect(Path::parse_posix("usr/./bin"), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
  @json.inspect(Path::parse_posix("usr/../bin"), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "..", "bin"],
  })
  @json.inspect(Path::parse_posix("usr/.././bin"), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "..", "bin"],
  })
  @json.inspect(Path::parse_posix("usr/./../bin"), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "..", "bin"],
  })
}

///|
pub fn Path::parse_windows(path : @string.View) -> Path {
  enum UncState {
    Zero
    One
  }
  let drive = StringBuilder::new()
  let root = StringBuilder::new()
  fn make_path(parts : Array[@string.View]) -> Path {
    let drive_string = drive.to_string()
    let root = root.to_string()
    drive.write_string(root)
    let anchor = drive.to_string()
    return Path::{ flavor: Windows, drive: drive_string, root, anchor, parts }
  }

  let parts : Array[@string.View] = []
  let part = StringBuilder::new()
  let path = match path {
    [drive_letter, ':', '/' | '\\', .. path] => {
      drive.write_char(drive_letter)
      drive.write_char(':')
      root.write_char('\\')
      parts.push("\{drive_letter}:\\")
      skip~: loop path {
        ['/' | '\\', .. path] => continue skip~ path
        [char, .. path] => {
          part.write_char(char)
          path
        }
        [] => return make_path(parts)
      }
    }
    [drive_letter, ':', char, .. path] => {
      drive.write_char(drive_letter)
      drive.write_char(':')
      parts.push("\{drive_letter}:")
      part.write_char(char)
      path
    }
    [drive_letter, ':'] => {
      drive.write_char(drive_letter)
      drive.write_char(':')
      parts.push("\{drive_letter}:")
      return make_path(parts)
    }
    ['/' | '\\', '/' | '\\', .. path] => {
      drive.write_string("\\\\")
      unc~: loop Zero, path {
        Zero, ['/' | '\\', .. path] => {
          drive.write_char('\\')
          continue unc~ One, path
        }
        Zero, [char, .. path] => {
          drive.write_char(char)
          continue unc~ Zero, path
        }
        Zero, [] => {
          parts.push(drive.to_string())
          return make_path(parts)
        }
        One, ['/' | '\\', .. path] => {
          root.write_char('\\')
          parts.push("\{drive.to_string()}\\")
          path
        }
        One, [char, .. path] => {
          drive.write_char(char)
          continue unc~ One, path
        }
        One, [] => {
          let drive = drive.to_string()
          if drive is [.., '\\'] {
            parts.push(drive)
            return make_path(parts)
          } else {
            root.write_char('\\')
            parts.push("\{drive.to_string()}\\")
            return make_path(parts)
          }
        }
      }
    }
    ['/' | '\\', char, .. path] => {
      root.write_char('\\')
      parts.push("\\")
      part.write_char(char)
      path
    }
    ['/' | '\\'] => {
      root.write_char('\\')
      parts.push("\\")
      return make_path(parts)
    }
    [char, .. path] => {
      part.write_char(char)
      path
    }
    [] => return make_path(parts)
  }
  fn push_part(part : String) {
    if part is ("" | ".") {
      return
    }
    parts.push(part)
  }

  path~: loop path {
    ['/' | '\\', .. path] => {
      push_part(part.to_string())
      skip~: loop path {
        ['/' | '\\', .. path] => continue skip~ path
        [char, .. path] => {
          part.reset()
          part.write_char(char)
          continue path~ path
        }
        [] => break path~ make_path(parts)
      }
    }
    [char, .. path] => {
      part.write_char(char)
      continue path~ path
    }
    [] => {
      push_part(part.to_string())
      break path~ make_path(parts)
    }
  }
}

///|
pub fn[ToWindowsPath : ToWindowsPath] Path::windows(
  path : ToWindowsPath
) -> Path {
  path.to_windows_path()
}

///|
test "parse_windows_path/empty" {
  @json.inspect(Path::parse_windows(""), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": [],
  })
}

///|
test "parse_windows_path/drive" {
  @json.inspect(Path::parse_windows("C:"), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "",
    "anchor": "C:",
    "parts": ["C:"],
  })
  @json.inspect(Path::parse_windows("ABC:"), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["ABC:"],
  })
  @json.inspect(Path::parse_windows("C:\\"), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\"],
  })
  @json.inspect(Path::parse_windows("C:\\\\"), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\"],
  })
  @json.inspect(Path::parse_windows("C:\\Windows"), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "Windows"],
  })
  @json.inspect(Path::parse_windows("C:\\\\Windows"), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "Windows"],
  })
  @json.inspect(Path::parse_windows("C:/Windows"), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "Windows"],
  })
  @json.inspect(Path::parse_windows("C:/Windows/"), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "Windows"],
  })
  @json.inspect(Path::parse_windows("C:\\Windows\\"), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "Windows"],
  })
  @json.inspect(Path::parse_windows("C:Windows"), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "",
    "anchor": "C:",
    "parts": ["C:", "Windows"],
  })
  @json.inspect(Path::parse_windows("C:Windows/"), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "",
    "anchor": "C:",
    "parts": ["C:", "Windows"],
  })
}

///|
test "parse_windows_path/root" {
  @json.inspect(Path::parse_windows("/"), content={
    "flavor": "windows",
    "drive": "",
    "root": "\\",
    "anchor": "\\",
    "parts": ["\\"],
  })
  @json.inspect(Path::parse_windows("\\"), content={
    "flavor": "windows",
    "drive": "",
    "root": "\\",
    "anchor": "\\",
    "parts": ["\\"],
  })
  @json.inspect(Path::parse_windows("Windows"), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["Windows"],
  })
  @json.inspect(Path::parse_windows("/Windows"), content={
    "flavor": "windows",
    "drive": "",
    "root": "\\",
    "anchor": "\\",
    "parts": ["\\", "Windows"],
  })
  @json.inspect(Path::parse_windows("\\Windows"), content={
    "flavor": "windows",
    "drive": "",
    "root": "\\",
    "anchor": "\\",
    "parts": ["\\", "Windows"],
  })
}

///|
test "parse_windows_path/unc" {
  @json.inspect(Path::parse_windows("//"), content={
    "flavor": "windows",
    "drive": "\\\\",
    "root": "",
    "anchor": "\\\\",
    "parts": ["\\\\"],
  })
  @json.inspect(Path::parse_windows("\\\\"), content={
    "flavor": "windows",
    "drive": "\\\\",
    "root": "",
    "anchor": "\\\\",
    "parts": ["\\\\"],
  })
  @json.inspect(Path::parse_windows("/\\"), content={
    "flavor": "windows",
    "drive": "\\\\",
    "root": "",
    "anchor": "\\\\",
    "parts": ["\\\\"],
  })
  @json.inspect(Path::parse_windows("///"), content={
    "flavor": "windows",
    "drive": "\\\\\\",
    "root": "",
    "anchor": "\\\\\\",
    "parts": ["\\\\\\"],
  })
  @json.inspect(Path::parse_windows("////"), content={
    "flavor": "windows",
    "drive": "\\\\\\",
    "root": "\\",
    "anchor": "\\\\\\\\",
    "parts": ["\\\\\\\\"],
  })
  @json.inspect(Path::parse_windows("/////"), content={
    "flavor": "windows",
    "drive": "\\\\\\",
    "root": "\\",
    "anchor": "\\\\\\\\",
    "parts": ["\\\\\\\\"],
  })
  @json.inspect(Path::parse_windows("//unc"), content={
    "flavor": "windows",
    "drive": "\\\\unc",
    "root": "",
    "anchor": "\\\\unc",
    "parts": ["\\\\unc"],
  })
  @json.inspect(Path::parse_windows("//unc/"), content={
    "flavor": "windows",
    "drive": "\\\\unc\\",
    "root": "",
    "anchor": "\\\\unc\\",
    "parts": ["\\\\unc\\"],
  })
  @json.inspect(Path::parse_windows("//unc/share"), content={
    "flavor": "windows",
    "drive": "\\\\unc\\share",
    "root": "\\",
    "anchor": "\\\\unc\\share\\",
    "parts": ["\\\\unc\\share\\"],
  })
  @json.inspect(Path::parse_windows("//unc/share/"), content={
    "flavor": "windows",
    "drive": "\\\\unc\\share",
    "root": "\\",
    "anchor": "\\\\unc\\share\\",
    "parts": ["\\\\unc\\share\\"],
  })
  @json.inspect(Path::parse_windows("\\\\unc\\share"), content={
    "flavor": "windows",
    "drive": "\\\\unc\\share",
    "root": "\\",
    "anchor": "\\\\unc\\share\\",
    "parts": ["\\\\unc\\share\\"],
  })
  @json.inspect(Path::parse_windows("\\\\unc\\share\\"), content={
    "flavor": "windows",
    "drive": "\\\\unc\\share",
    "root": "\\",
    "anchor": "\\\\unc\\share\\",
    "parts": ["\\\\unc\\share\\"],
  })
  @json.inspect(Path::parse_windows("//unc/share/a/b"), content={
    "flavor": "windows",
    "drive": "\\\\unc\\share",
    "root": "\\",
    "anchor": "\\\\unc\\share\\",
    "parts": ["\\\\unc\\share\\", "a", "b"],
  })
  @json.inspect(Path::parse_windows("\\\\unc\\share\\a\\b"), content={
    "flavor": "windows",
    "drive": "\\\\unc\\share",
    "root": "\\",
    "anchor": "\\\\unc\\share\\",
    "parts": ["\\\\unc\\share\\", "a", "b"],
  })
}

///|
test "parse_windows_path/collapse_slashes" {
  @json.inspect(Path::parse_windows("a//b///c////d"), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c", "d"],
  })
  @json.inspect(Path::parse_windows("a\\\\b\\\\\\c\\\\\\\\d"), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c", "d"],
  })
  @json.inspect(Path::parse_windows("a/b/c/d"), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c", "d"],
  })
}

///|
test "parse_windows_path/collapse_dots" {
  @json.inspect(Path::parse_windows("./a/b/c"), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c"],
  })
  @json.inspect(Path::parse_windows("a/b/c/."), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c"],
  })
  @json.inspect(Path::parse_windows("a/b/c/./d"), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c", "d"],
  })
  @json.inspect(Path::parse_windows("a/b/c/././d"), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c", "d"],
  })
  @json.inspect(Path::parse_windows("a/b/c/./././d"), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c", "d"],
  })
  @json.inspect(Path::parse_windows("//./"), content={
    "flavor": "windows",
    "drive": "\\\\.\\",
    "root": "",
    "anchor": "\\\\.\\",
    "parts": ["\\\\.\\"],
  })
  @json.inspect(Path::parse_windows("//./."), content={
    "flavor": "windows",
    "drive": "\\\\.\\.",
    "root": "\\",
    "anchor": "\\\\.\\.\\",
    "parts": ["\\\\.\\.\\"],
  })
  @json.inspect(Path::parse_windows("//./././a/b/c"), content={
    "flavor": "windows",
    "drive": "\\\\.\\.",
    "root": "\\",
    "anchor": "\\\\.\\.\\",
    "parts": ["\\\\.\\.\\", "a", "b", "c"],
  })
}

///|
pub impl Show for Path with output(self : Path, logger : &Logger) -> Unit {
  let separator = if self.flavor is Windows { '\\' } else { '/' }
  fn write_stringview(s : @string.View) {
    for c in s {
      logger.write_char(c)
    }
  }

  if self.drive != "" || self.root != "" {
    write_stringview(self.drive)
    write_stringview(self.root)
    let parts = self.parts[1:]
    for i, part in parts {
      write_stringview(part)
      if i < parts.length() - 1 {
        logger.write_char(separator)
      }
    }
  } else {
    for i, part in self.parts {
      write_stringview(part)
      if i < self.parts.length() - 1 {
        logger.write_char(separator)
      }
    }
  }
}

///|
pub fn Path::parent(self : Path) -> Path? {
  if self.parts.length() == 0 {
    return None
  }
  if (self.drive != "" || self.root != "") && self.parts.length() == 1 {
    return None
  }
  Some(Path::{ ..self, parts: self.parts[:self.parts.length() - 1] })
}

///|
test "BasicPath::parent" {
  let path = Path::{
    flavor: Posix,
    drive: "",
    root: "",
    anchor: "",
    parts: ["usr", "bin"],
  }
  @json.inspect(path.parent(), content=[
    {
      "flavor": "posix",
      "drive": "",
      "root": "",
      "anchor": "",
      "parts": ["usr"],
    },
  ])
  let path = Path::{
    flavor: Posix,
    drive: "",
    root: "/",
    anchor: "/",
    parts: ["/", "usr", "bin"],
  }
  @json.inspect(path.parent(), content=[
    {
      "flavor": "posix",
      "drive": "",
      "root": "/",
      "anchor": "/",
      "parts": ["/", "usr"],
    },
  ])
  let path = Path::{
    flavor: Windows,
    drive: "C:",
    root: "\\",
    anchor: "C:\\",
    parts: ["C:\\", "Windows", "System32"],
  }
  @json.inspect(path.parent(), content=[
    {
      "flavor": "windows",
      "drive": "C:",
      "root": "\\",
      "anchor": "C:\\",
      "parts": ["C:\\", "Windows"],
    },
  ])
  let path = Path::{
    flavor: Windows,
    drive: "C:",
    root: "\\",
    anchor: "C:\\",
    parts: ["C:\\"],
  }
  @json.inspect(path.parent() is None, content=true)
  let path = Path::{
    flavor: Windows,
    drive: "",
    root: "",
    anchor: "",
    parts: [],
  }
  @json.inspect(path.parent() is None, content=true)
}

///|
pub fn Path::to_posix_path(self : Path) -> Path {
  fn convert_to_slash(source : @string.View, target : StringBuilder) -> Unit {
    loop source {
      ['\\', .. chars] => {
        target.write_char('/')
        continue chars
      }
      [char, .. chars] => {
        target.write_char(char)
        continue chars
      }
      [] => ()
    }
  }

  if self.flavor is Posix {
    self
  } else if self.drive != "" || self.root != "" {
    let anchor = StringBuilder::new()
    convert_to_slash(self.drive, anchor)
    convert_to_slash(self.root, anchor)
    let anchor = Path::parse_posix(anchor.to_string())
    Path::{ ..anchor, parts: [..anchor.parts, ..self.parts[1:]] }
  } else {
    Path::{ ..self, flavor: Posix }
  }
}

///|
pub fn Path::to_windows_path(self : Path) -> Path {
  if self.flavor is Windows {
    self
  } else {
    Path::parse_windows(self.to_string())
  }
}

///|
pub fn[ToPath : ToPath] Path::relative_to(self : Path, other : ToPath) -> Path {
  let other = other.to_path()
  let self_parts_length = self.parts.length()
  let other_parts_length = other.parts.length()
  let minimum_parts_length = @math.minimum(
    self_parts_length, other_parts_length,
  )
  let start_index = if self.anchor != "" { 1 } else { 0 }
  let common_parts_length = for i in start_index..<minimum_parts_length {
    if self.parts[i] != other.parts[i] {
      break i
    }
  } else {
    minimum_parts_length
  }
  let parts : Array[@string.View] = []
  for i in common_parts_length..<other_parts_length {
    parts.push("..")
  }
  for i in common_parts_length..<self_parts_length {
    parts.push(self.parts[i])
  }
  Path::{ ..self, drive: "", root: "", anchor: "", parts }
}

///|
impl Div for Path with op_div(self : Path, other : Path) -> Path {
  match self.flavor {
    Windows => {
      let other = other.to_windows_path()
      if other.drive != "" {
        return other
      }
      if other.root != "" {
        return Path::{
          flavor: Windows,
          drive: self.drive,
          root: other.root,
          anchor: [..self.drive, ..other.root],
          parts: other.parts,
        }
      }
      Path::{ ..self, parts: [..self.parts, ..other.parts] }
    }
    Posix => {
      let other = other.to_posix_path()
      if other.root != "" {
        return other
      }
      Path::{ ..self, parts: [..self.parts, ..other.parts] }
    }
  }
}

///|
pub fn[ToPath : ToPath] Path::join(self : Path, other : ToPath) -> Path {
  self / other.to_path()
}

///|
test "BasicPath::op_div" {
  let a = Path::{
    flavor: Posix,
    drive: "",
    root: "",
    anchor: "",
    parts: ["usr", "bin"],
  }
  let b = Path::{
    flavor: Posix,
    drive: "",
    root: "",
    anchor: "",
    parts: ["local", "bin"],
  }
  let c = a / b
  inspect(c, content="usr/bin/local/bin")
  let a = Path::{
    flavor: Posix,
    drive: "",
    root: "/",
    anchor: "/",
    parts: ["/", "usr", "bin"],
  }
  let b = Path::{
    flavor: Posix,
    drive: "",
    root: "",
    anchor: "",
    parts: ["local", "bin"],
  }
  let c = a / b
  inspect(c, content="/usr/bin/local/bin")
  let a = Path::{
    flavor: Posix,
    drive: "",
    root: "",
    anchor: "",
    parts: ["usr", "bin"],
  }
  let b = Path::{
    flavor: Posix,
    drive: "",
    root: "/",
    anchor: "/",
    parts: ["/", "local", "bin"],
  }
  let c = a / b
  inspect(c, content="/local/bin")
  let a = Path::{
    flavor: Windows,
    drive: "C:",
    root: "\\",
    anchor: "C:\\",
    parts: ["C:\\", "Windows"],
  }
  let b = Path::{
    flavor: Windows,
    drive: "",
    root: "",
    anchor: "",
    parts: ["System32"],
  }
  let c = a / b
  inspect(c, content="C:\\Windows\\System32")
  let a = Path::{
    flavor: Windows,
    drive: "C:",
    root: "\\",
    anchor: "C:\\",
    parts: ["C:\\", "Windows"],
  }
  let b = Path::{
    flavor: Windows,
    drive: "D:",
    root: "\\",
    anchor: "D:\\",
    parts: ["D:\\", "System32"],
  }
  let c = a / b
  inspect(c, content="D:\\System32")
  let a = Path::{
    flavor: Windows,
    drive: "C:",
    root: "\\",
    anchor: "C:\\",
    parts: ["C:\\", "Windows"],
  }
  let b = Path::{
    flavor: Windows,
    drive: "",
    root: "\\",
    anchor: "\\",
    parts: ["\\", "System32"],
  }
  let c = a / b
  inspect(c, content="C:\\System32")
}

///|
pub fn Path::suffix(self : Path) -> @string.View? {
  guard self.name() is Some(name) else { None }
  name.split(".").last()
}

///|
pub fn Path::name(self : Path) -> @string.View? {
  let parts_length = self.parts.length()
  if self.anchor != "" && self.parts.length() == 1 {
    return None
  }
  Some(self.parts[parts_length - 1])
}

///|
let flavor : Ref[Flavor] = Ref::new(Posix)

///|
fn init {
  try {
    if @uv.os_uname().sysname() == "Windows_NT" {
      flavor.val = Windows
    }
  } catch {
    e => println("Warning: Failed to determine OS, defaulting to Posix: \{e}")
  }
}

///|
pub trait ToPath {
  to_path(Self) -> Path
}

///|
pub impl ToPath for @string.View with to_path(self : @string.View) -> Path {
  match flavor.val {
    Windows => ToWindowsPath::to_windows_path(self)
    Posix => ToPosixPath::to_posix_path(self)
  }
}

///|
pub impl ToPath for String with to_path(self : String) -> Path {
  ToPath::to_path(self.view())
}

///|
pub impl ToPath for Path with to_path(self : Path) -> Path {
  self
}

///|
pub impl ToPath for &ToWindowsPath with to_path(self : &ToWindowsPath) -> Path {
  self.to_windows_path()
}

///|
pub impl ToPath for &ToPosixPath with to_path(self : &ToPosixPath) -> Path {
  self.to_posix_path()
}

///|
pub impl[T : ToPath] ToPath for Array[T] with to_path(self : Array[T]) -> Path {
  ToPath::to_path(self[:])
}

///|
pub impl[T : ToPath] ToPath for ArrayView[T] with to_path(self : ArrayView[T]) -> Path {
  let mut path = Path::{
    flavor: flavor.val,
    drive: "",
    root: "",
    anchor: "",
    parts: [],
  }
  for item in self {
    path = path / item.to_path()
  }
  path
}

///|
pub fn[ToPath : ToPath] Path::new(path : ToPath) -> Path {
  path.to_path()
}

///|
pub fn Path::parse(path : @string.View) -> Path {
  match flavor.val {
    Windows => Path::parse_windows(path)
    Posix => Path::parse_posix(path)
  }
}

///|
pub fn[ToPath : ToPath] &ToPath::new(path : ToPath) -> &ToPath {
  path.to_path()
}

///|
pub fn[ToPath : ToPath] path(path : ToPath) -> &ToPath {
  path.to_path()
}

///|
pub fn &ToPath::parts(self : &ToPath) -> ArrayView[@string.View] {
  self.to_path().parts
}

///|
pub fn &ToPath::drive(self : &ToPath) -> @string.View {
  self.to_path().drive
}

///|
pub fn &ToPath::root(self : &ToPath) -> @string.View {
  return self.to_path().root
}

///|
pub fn &ToPath::anchor(self : &ToPath) -> @string.View {
  self.to_path().anchor
}

///|
pub fn &ToPath::parent(self : &ToPath) -> &ToPath? {
  match self.to_path().parent() {
    None => None
    Some(parent) => Some(parent)
  }
}

///|
pub fn &ToPath::to_windows_path(self : &ToPath) -> &ToWindowsPath {
  match self.to_path().flavor {
    Windows => {
      self as &ToWindowsPath
    }
    Posix => {
      &ToPosixPath::to_posix_path(self) as &ToWindowsPath
    }
  }
}

///|
pub fn &ToPath::to_posix_path(self : &ToPath) -> &ToPosixPath {
  match self.to_path().flavor {
    Posix => {
      self as &ToPosixPath
    }
    Windows => {
      &ToWindowsPath::to_windows_path(self) as &ToPosixPath
    }
  }
}

///|
pub impl Show for &ToPath with output(self : &ToPath, logger : &Logger) -> Unit {
  self.to_path().output(logger)
}

///|
pub impl Div for &ToPath with op_div(self : &ToPath, other : &ToPath) -> &ToPath {
  let self = self.to_path()
  match self.flavor {
    Windows => {
      &ToWindowsPath::op_div(self, other) as &ToPath
    }
    Posix => {
      &ToPosixPath::op_div(self, other) as &ToPath
    }
  }
}

///|
pub fn[ToPath : ToPath] &ToPath::join(
  self : &ToPath,
  other : ToPath
) -> &ToPath {
  self / other
}

///|
pub impl ToJson for &ToPath with to_json(self : &ToPath) -> Json {
  return self.to_string().to_json()
}

///|
pub impl Eq for &ToPath with op_equal(self : &ToPath, other : &ToPath) -> Bool {
  self.to_path() == other.to_path()
}

///|
pub impl Compare for &ToPath with compare(self : &ToPath, other : &ToPath) -> Int {
  self.to_path().compare(other.to_path())
}

///|
pub impl Hash for &ToPath with hash_combine(self : &ToPath, hasher : Hasher) -> Unit {
  self.to_path().hash_combine(hasher)
}

///|
pub fn &ToPath::relative_to(self : &ToPath, other : &ToPath) -> &ToPath {
  self.to_path().relative_to(other.to_path())
}

///|
pub fn &ToPath::suffix(self : &ToPath) -> @string.View? {
  self.to_path().suffix()
}

///|
pub fn &ToPath::name(self : &ToPath) -> @string.View? {
  self.to_path().name()
}

///|
trait ToPosixPath {
  to_posix_path(Self) -> Path
}

///|
pub typealias PosixPath = &ToPosixPath

///|
pub impl ToPosixPath for @string.View with to_posix_path(self : @string.View) -> Path {
  Path::parse_posix(self)
}

///|
pub impl ToPosixPath for String with to_posix_path(self : String) -> Path {
  Path::parse_posix(self.view())
}

///|
impl ToPosixPath for Path with to_posix_path(self : Path) -> Path {
  self.to_posix_path()
}

///|
pub impl ToPosixPath for &ToPath with to_posix_path(self : &ToPath) -> Path {
  self.to_path().to_posix_path()
}

///|
pub fn[ToPosixPath : ToPosixPath] &ToPosixPath::new(
  path : ToPosixPath
) -> &ToPosixPath {
  path
}

///|
pub fn[ToPosixPath : ToPosixPath] posix_path(
  path : ToPosixPath
) -> &ToPosixPath {
  path
}

///|
pub impl Show for &ToPosixPath with output(
  self : &ToPosixPath,
  logger : &Logger
) -> Unit {
  self.to_posix_path().output(logger)
}

///|
pub impl ToJson for &ToPosixPath with to_json(self : &ToPosixPath) -> Json {
  self.to_string().to_json()
}

///|
pub fn &ToPosixPath::parts(self : &ToPosixPath) -> ArrayView[@string.View] {
  self.to_posix_path().parts
}

///|
pub fn &ToPosixPath::root(self : &ToPosixPath) -> @string.View {
  self.to_posix_path().root
}

///|
pub fn &ToPosixPath::anchor(self : &ToPosixPath) -> @string.View {
  self.to_posix_path().anchor
}

///|
pub fn &ToPosixPath::parent(self : &ToPosixPath) -> &ToPosixPath? {
  match self.to_posix_path().parent() {
    None => None
    Some(parent) => Some(parent as &ToPosixPath)
  }
}

///|
pub fn &ToPosixPath::to_windows_path(self : &ToPosixPath) -> &ToWindowsPath {
  self.to_posix_path().to_windows_path()
}

///|
pub fn &ToPosixPath::relative_to(
  self : &ToPosixPath,
  other : &ToPosixPath
) -> &ToPosixPath {
  self.to_posix_path().relative_to(other.to_posix_path())
}

///|
pub impl Div for &ToPosixPath with op_div(
  self : &ToPosixPath,
  other : &ToPosixPath
) -> &ToPosixPath {
  let self = self.to_posix_path()
  let other = other.to_posix_path()
  if other.root != "" {
    return other
  }
  Path::{ ..self, parts: [..self.parts, ..other.parts] }
}

///|
pub fn &ToPosixPath::to_path(self : &ToPosixPath) -> &ToPath {
  self.to_posix_path() as &ToPath
}

///|
trait ToWindowsPath {
  to_windows_path(Self) -> Path
}

///|
pub typealias WindowsPath = &ToWindowsPath

///|
pub impl ToWindowsPath for @string.View with to_windows_path(
  self : @string.View
) -> Path {
  Path::parse_windows(self)
}

///|
pub impl ToWindowsPath for String with to_windows_path(self : String) -> Path {
  Path::parse_windows(self.view())
}

///|
impl ToWindowsPath for Path with to_windows_path(self : Path) -> Path {
  self.to_windows_path()
}

///|
pub impl ToWindowsPath for &ToPath with to_windows_path(self : &ToPath) -> Path {
  self.to_path().to_windows_path()
}

///|
pub fn[ToWindowsPath : ToWindowsPath] &ToWindowsPath::new(
  path : ToWindowsPath
) -> &ToWindowsPath {
  path.to_windows_path()
}

///|
pub fn[ToWindowsPath : ToWindowsPath] windows_path(
  path : ToWindowsPath
) -> &ToWindowsPath {
  path.to_windows_path()
}

///|
pub impl Show for &ToWindowsPath with output(
  self : &ToWindowsPath,
  logger : &Logger
) -> Unit {
  self.to_windows_path().output(logger)
}

///|
pub impl ToJson for &ToWindowsPath with to_json(self : &ToWindowsPath) -> Json {
  self.to_string().to_json()
}

///|
pub fn &ToWindowsPath::parts(self : &ToWindowsPath) -> ArrayView[@string.View] {
  self.to_windows_path().parts
}

///|
pub fn &ToWindowsPath::drive(self : &ToWindowsPath) -> @string.View {
  self.to_windows_path().drive
}

///|
pub fn &ToWindowsPath::root(self : &ToWindowsPath) -> @string.View {
  return self.to_windows_path().root
}

///|
pub fn &ToWindowsPath::anchor(self : &ToWindowsPath) -> @string.View {
  self.to_windows_path().anchor
}

///|
pub fn &ToWindowsPath::parent(self : &ToWindowsPath) -> &ToWindowsPath? {
  match self.to_windows_path().parent() {
    None => None
    Some(parent) => Some(parent)
  }
}

///|
pub fn &ToWindowsPath::to_posix_path(self : &ToWindowsPath) -> &ToPosixPath {
  self.to_windows_path().to_posix_path()
}

///|
pub impl Div for &ToWindowsPath with op_div(
  self : &ToWindowsPath,
  other : &ToWindowsPath
) -> &ToWindowsPath {
  let self = self.to_windows_path()
  let other = other.to_windows_path()
  if other.drive != "" {
    return other
  }
  if other.root != "" {
    return Path::{
      flavor: Windows,
      drive: self.drive,
      root: other.root,
      anchor: [..self.drive, ..other.root],
      parts: other.parts,
    }
  }
  Path::{ ..self, parts: [..self.parts, ..other.parts] }
}

///|
pub fn &ToWindowsPath::relative_to(
  self : &ToWindowsPath,
  other : &ToWindowsPath
) -> &ToWindowsPath {
  self.to_windows_path().relative_to(other.to_windows_path())
}
