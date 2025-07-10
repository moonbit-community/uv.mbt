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
priv enum Flavor {
  Windows
  Posix
} derive(Eq, Compare, Hash)

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
} derive(Eq, Hash)

///|
pub impl ToJson for Path with to_json(self : Path) -> Json {
  self.to_string().to_json()
}

///|
fn Path::inspect(self : Path) -> Json {
  {
    "flavor": self.flavor,
    "drive": self.drive,
    "root": self.root,
    "anchor": self.anchor,
    "parts": self.parts,
  }
}

///|
pub impl @json.FromJson for Path with from_json(
  json : Json,
  path : @json.JsonPath,
) -> Path {
  let string : String = @json.FromJson::from_json(json, path)
  Path::parse(string)
}

///|
pub fn Path::parts(self : Path) -> @builtin.Iter[@string.View] {
  self.parts.iter()
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
  if self.anchor != other.anchor {
    return self.anchor.compare(other.anchor)
  }
  return self.parts.compare(other.parts)
}

///|
fn Path::parse_posix(path : @string.View) -> Path {
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
  @json.inspect(Path::parse_posix("/").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/"],
  })
  @json.inspect(Path::parse_posix("//").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "//",
    "anchor": "//",
    "parts": ["//"],
  })
  @json.inspect(Path::parse_posix("///").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/"],
  })
  @json.inspect(Path::parse_posix("//usr//bin//").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "//",
    "anchor": "//",
    "parts": ["//", "usr", "bin"],
  })
  @json.inspect(Path::parse_posix("////usr").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/", "usr"],
  })
  @json.inspect(Path::parse_posix("/usr/bin").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/", "usr", "bin"],
  })
}

///|
test "posix_path" {
  @json.inspect(Path::parse_posix("usr/bin").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
  @json.inspect(Path::parse_posix("usr/bin/").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
  @json.inspect(Path::parse_posix("usr//bin").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
  @json.inspect(Path::parse_posix("C:\\Windows").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["C:\\Windows"],
  })
}

///|
test "posix_path/empty" {
  @json.inspect(Path::parse_posix("").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": [],
  })
}

///|
test "posix_path/collapse_slashes" {
  @json.inspect(Path::parse_posix("usr/////bin").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
  @json.inspect(Path::parse_posix("usr//bin//").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
  @json.inspect(Path::parse_posix("usr///bin//").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
}

///|
test "posix_path/collapse_dots" {
  @json.inspect(Path::parse_posix("usr/./bin").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin"],
  })
  @json.inspect(Path::parse_posix("usr/../bin").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "..", "bin"],
  })
  @json.inspect(Path::parse_posix("usr/.././bin").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "..", "bin"],
  })
  @json.inspect(Path::parse_posix("usr/./../bin").inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "..", "bin"],
  })
}

///|
fn Path::parse_windows(path : @string.View) -> Path {
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
      unc~: loop (Zero, path) {
        (Zero, ['/' | '\\', .. path]) => {
          drive.write_char('\\')
          continue unc~ (One, path)
        }
        (Zero, [char, .. path]) => {
          drive.write_char(char)
          continue unc~ (Zero, path)
        }
        (Zero, []) => {
          parts.push(drive.to_string())
          return make_path(parts)
        }
        (One, ['/' | '\\', .. path]) => {
          root.write_char('\\')
          parts.push("\{drive.to_string()}\\")
          path
        }
        (One, [char, .. path]) => {
          drive.write_char(char)
          continue unc~ (One, path)
        }
        (One, []) => {
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
test "parse_windows_path/empty" {
  @json.inspect(Path::parse_windows("").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": [],
  })
}

///|
test "parse_windows_path/drive" {
  @json.inspect(Path::parse_windows("C:").inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "",
    "anchor": "C:",
    "parts": ["C:"],
  })
  @json.inspect(Path::parse_windows("ABC:").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["ABC:"],
  })
  @json.inspect(Path::parse_windows("C:\\").inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\"],
  })
  @json.inspect(Path::parse_windows("C:\\\\").inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\"],
  })
  @json.inspect(Path::parse_windows("C:\\Windows").inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "Windows"],
  })
  @json.inspect(Path::parse_windows("C:\\\\Windows").inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "Windows"],
  })
  @json.inspect(Path::parse_windows("C:/Windows").inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "Windows"],
  })
  @json.inspect(Path::parse_windows("C:/Windows/").inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "Windows"],
  })
  @json.inspect(Path::parse_windows("C:\\Windows\\").inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "Windows"],
  })
  @json.inspect(Path::parse_windows("C:Windows").inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "",
    "anchor": "C:",
    "parts": ["C:", "Windows"],
  })
  @json.inspect(Path::parse_windows("C:Windows/").inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "",
    "anchor": "C:",
    "parts": ["C:", "Windows"],
  })
}

///|
test "parse_windows_path/root" {
  @json.inspect(Path::parse_windows("/").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "\\",
    "anchor": "\\",
    "parts": ["\\"],
  })
  @json.inspect(Path::parse_windows("\\").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "\\",
    "anchor": "\\",
    "parts": ["\\"],
  })
  @json.inspect(Path::parse_windows("Windows").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["Windows"],
  })
  @json.inspect(Path::parse_windows("/Windows").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "\\",
    "anchor": "\\",
    "parts": ["\\", "Windows"],
  })
  @json.inspect(Path::parse_windows("\\Windows").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "\\",
    "anchor": "\\",
    "parts": ["\\", "Windows"],
  })
}

///|
test "parse_windows_path/unc" {
  @json.inspect(Path::parse_windows("//").inspect(), content={
    "flavor": "windows",
    "drive": "\\\\",
    "root": "",
    "anchor": "\\\\",
    "parts": ["\\\\"],
  })
  @json.inspect(Path::parse_windows("\\\\").inspect(), content={
    "flavor": "windows",
    "drive": "\\\\",
    "root": "",
    "anchor": "\\\\",
    "parts": ["\\\\"],
  })
  @json.inspect(Path::parse_windows("/\\").inspect(), content={
    "flavor": "windows",
    "drive": "\\\\",
    "root": "",
    "anchor": "\\\\",
    "parts": ["\\\\"],
  })
  @json.inspect(Path::parse_windows("///").inspect(), content={
    "flavor": "windows",
    "drive": "\\\\\\",
    "root": "",
    "anchor": "\\\\\\",
    "parts": ["\\\\\\"],
  })
  @json.inspect(Path::parse_windows("////").inspect(), content={
    "flavor": "windows",
    "drive": "\\\\\\",
    "root": "\\",
    "anchor": "\\\\\\\\",
    "parts": ["\\\\\\\\"],
  })
  @json.inspect(Path::parse_windows("/////").inspect(), content={
    "flavor": "windows",
    "drive": "\\\\\\",
    "root": "\\",
    "anchor": "\\\\\\\\",
    "parts": ["\\\\\\\\"],
  })
  @json.inspect(Path::parse_windows("//unc").inspect(), content={
    "flavor": "windows",
    "drive": "\\\\unc",
    "root": "",
    "anchor": "\\\\unc",
    "parts": ["\\\\unc"],
  })
  @json.inspect(Path::parse_windows("//unc/").inspect(), content={
    "flavor": "windows",
    "drive": "\\\\unc\\",
    "root": "",
    "anchor": "\\\\unc\\",
    "parts": ["\\\\unc\\"],
  })
  @json.inspect(Path::parse_windows("//unc/share").inspect(), content={
    "flavor": "windows",
    "drive": "\\\\unc\\share",
    "root": "\\",
    "anchor": "\\\\unc\\share\\",
    "parts": ["\\\\unc\\share\\"],
  })
  @json.inspect(Path::parse_windows("//unc/share/").inspect(), content={
    "flavor": "windows",
    "drive": "\\\\unc\\share",
    "root": "\\",
    "anchor": "\\\\unc\\share\\",
    "parts": ["\\\\unc\\share\\"],
  })
  @json.inspect(
    Path::parse_windows("\\\\unc\\share"),
    content="\\\\unc\\share\\",
  )
  @json.inspect(
    Path::parse_windows("\\\\unc\\share\\"),
    content="\\\\unc\\share\\",
  )
  @json.inspect(
    Path::parse_windows("//unc/share/a/b"),
    content="\\\\unc\\share\\a\\b",
  )
  @json.inspect(
    Path::parse_windows("\\\\unc\\share\\a\\b"),
    content="\\\\unc\\share\\a\\b",
  )
}

///|
test "parse_windows_path/collapse_slashes" {
  @json.inspect(Path::parse_windows("a//b///c////d").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c", "d"],
  })
  @json.inspect(Path::parse_windows("a\\\\b\\\\\\c\\\\\\\\d").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c", "d"],
  })
  @json.inspect(Path::parse_windows("a/b/c/d").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c", "d"],
  })
}

///|
test "parse_windows_path/collapse_dots" {
  @json.inspect(Path::parse_windows("./a/b/c").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c"],
  })
  @json.inspect(Path::parse_windows("a/b/c/.").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c"],
  })
  @json.inspect(Path::parse_windows("a/b/c/./d").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c", "d"],
  })
  @json.inspect(Path::parse_windows("a/b/c/././d").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c", "d"],
  })
  @json.inspect(Path::parse_windows("a/b/c/./././d").inspect(), content={
    "flavor": "windows",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["a", "b", "c", "d"],
  })
  @json.inspect(Path::parse_windows("//./").inspect(), content={
    "flavor": "windows",
    "drive": "\\\\.\\",
    "root": "",
    "anchor": "\\\\.\\",
    "parts": ["\\\\.\\"],
  })
  @json.inspect(Path::parse_windows("//./.").inspect(), content={
    "flavor": "windows",
    "drive": "\\\\.\\.",
    "root": "\\",
    "anchor": "\\\\.\\.\\",
    "parts": ["\\\\.\\.\\"],
  })
  @json.inspect(Path::parse_windows("//./././a/b/c").inspect(), content={
    "flavor": "windows",
    "drive": "\\\\.\\.",
    "root": "\\",
    "anchor": "\\\\.\\.\\",
    "parts": ["\\\\.\\.\\", "a", "b", "c"],
  })
}

///|
pub impl Show for Path with output(self : Path, logger : &Logger) -> Unit {
  if self.anchor == "" && self.parts is [] {
    logger.write_char('.')
    return
  }
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
  @json.inspect(path.parent(), content=["usr"])
  let path = Path::{
    flavor: Posix,
    drive: "",
    root: "/",
    anchor: "/",
    parts: ["/", "usr", "bin"],
  }
  @json.inspect(path.parent(), content=["/usr"])
  let path = Path::{
    flavor: Windows,
    drive: "C:",
    root: "\\",
    anchor: "C:\\",
    parts: ["C:\\", "Windows", "System32"],
  }
  @json.inspect(path.parent(), content=["C:\\Windows"])
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
fn[T : Compare] min(a : T, b : T) -> T {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn[ToPath : ToPath] Path::relative_to(self : Path, other : ToPath) -> Path {
  let other = other.to_path()
  let self_parts_length = self.parts.length()
  let other_parts_length = other.parts.length()
  let minimum_parts_length = min(self_parts_length, other_parts_length)
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
pub fn[ToPath : ToPath] Path::join(self : Path, other : ToPath) -> Path {
  let other = other.to_path()
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
test "Path::join" {
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
  let c = a.join(b)
  @json.inspect(c.inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "",
    "anchor": "",
    "parts": ["usr", "bin", "local", "bin"],
  })
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
  let c = a.join(b)
  @json.inspect(c.inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/", "usr", "bin", "local", "bin"],
  })
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
  let c = a.join(b)
  @json.inspect(c.inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/", "local", "bin"],
  })
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
  let c = a.join(b)
  @json.inspect(c.inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "Windows", "System32"],
  })
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
  let c = a.join(b)
  @json.inspect(c.inspect(), content={
    "flavor": "windows",
    "drive": "D:",
    "root": "\\",
    "anchor": "D:\\",
    "parts": ["D:\\", "System32"],
  })
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
  let c = a.join(b)
  @json.inspect(c.inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["\\", "System32"],
  })
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
pub impl ToPath for String with to_path(self : String) -> Path {
  ToPath::to_path(self.view())
}

///|
pub impl ToPath for @string.View with to_path(self : @string.View) -> Path {
  match flavor.val {
    Windows => Path::parse_windows(self)
    Posix => Path::parse_posix(self)
  }
}

///|
pub impl ToPath for Path with to_path(self : Path) -> Path {
  self
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
    path = path.join(item.to_path())
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
pub fn[ToPath : ToPath] path(path : ToPath) -> Path {
  path.to_path()
}

///|
test "concat" {
  let win_path = Path::parse_windows("C:\\a\\b")
  let unc_path = Path::parse_windows("\\\\server\\share\\a\\b")
  let win_rel_path = Path::parse_windows("a\\b")
  let nix_abs_path = Path::parse_posix("/c/d")
  let nix_ds_path = Path::parse_posix("//c/d")
  let nix_rel_path = Path::parse_posix("c/d")
  @json.inspect(win_path.join(win_path).inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "a", "b"],
  })
  @json.inspect(win_path.join(unc_path).inspect(), content={
    "flavor": "windows",
    "drive": "\\\\server\\share",
    "root": "\\",
    "anchor": "\\\\server\\share\\",
    "parts": ["\\\\server\\share\\", "a", "b"],
  })
  @json.inspect(win_path.join(win_rel_path).inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "a", "b", "a", "b"],
  })
  @json.inspect(win_path.join(nix_abs_path).inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["\\", "c", "d"],
  })
  @json.inspect(win_path.join(nix_ds_path).inspect(), content={
    "flavor": "windows",
    "drive": "\\\\c\\d",
    "root": "\\",
    "anchor": "\\\\c\\d\\",
    "parts": ["\\\\c\\d\\"],
  })
  @json.inspect(win_path.join(nix_ds_path).drive(), content="\\\\c\\d")
  @json.inspect(win_path.join(nix_ds_path).root(), content="\\")
  @json.inspect(win_path.join(nix_rel_path).inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "a", "b", "c", "d"],
  })
  @json.inspect(unc_path.join(win_path).inspect(), content={
    "flavor": "windows",
    "drive": "C:",
    "root": "\\",
    "anchor": "C:\\",
    "parts": ["C:\\", "a", "b"],
  })
  @json.inspect(unc_path.join(win_rel_path).inspect(), content={
    "flavor": "windows",
    "drive": "\\\\server\\share",
    "root": "\\",
    "anchor": "\\\\server\\share\\",
    "parts": ["\\\\server\\share\\", "a", "b", "a", "b"],
  })
  @json.inspect(unc_path.join(unc_path).inspect(), content={
    "flavor": "windows",
    "drive": "\\\\server\\share",
    "root": "\\",
    "anchor": "\\\\server\\share\\",
    "parts": ["\\\\server\\share\\", "a", "b"],
  })
  @json.inspect(
    unc_path.join(nix_abs_path.to_windows_path()),
    content="\\\\server\\share\\c\\d",
  )
  @json.inspect(unc_path.join(nix_ds_path).inspect(), content={
    "flavor": "windows",
    "drive": "\\\\c\\d",
    "root": "\\",
    "anchor": "\\\\c\\d\\",
    "parts": ["\\\\c\\d\\"],
  })
  @json.inspect(unc_path.join(nix_ds_path).drive(), content="\\\\c\\d")
  @json.inspect(unc_path.join(nix_ds_path).root(), content="\\")
  @json.inspect(unc_path.join(nix_rel_path).inspect(), content={
    "flavor": "windows",
    "drive": "\\\\server\\share",
    "root": "\\",
    "anchor": "\\\\server\\share\\",
    "parts": ["\\\\server\\share\\", "a", "b", "c", "d"],
  })
  @json.inspect(nix_abs_path.join(win_path.to_posix_path()).inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/", "c", "d", "C:", "a", "b"],
  })
  @json.inspect(
    nix_abs_path.join(unc_path.to_posix_path()),
    content="//server/share/a/b",
  )
  @json.inspect(nix_abs_path.join(win_rel_path.to_posix_path()).inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/", "c", "d", "a", "b"],
  })
  @json.inspect(nix_abs_path.join(nix_abs_path).inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/", "c", "d"],
  })
  @json.inspect(nix_abs_path.join(nix_ds_path).inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "//",
    "anchor": "//",
    "parts": ["//", "c", "d"],
  })
  @json.inspect(nix_abs_path.join(nix_rel_path).inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/", "c", "d", "c", "d"],
  })
  @json.inspect(nix_ds_path.join(win_path.to_posix_path()).inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "//",
    "anchor": "//",
    "parts": ["//", "c", "d", "C:", "a", "b"],
  })
  @json.inspect(
    nix_ds_path.join(unc_path.to_posix_path()),
    content="//server/share/a/b",
  )
  @json.inspect(nix_ds_path.join(win_rel_path.to_posix_path()).inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "//",
    "anchor": "//",
    "parts": ["//", "c", "d", "a", "b"],
  })
  @json.inspect(nix_ds_path.join(nix_abs_path).inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "/",
    "anchor": "/",
    "parts": ["/", "c", "d"],
  })
  @json.inspect(nix_ds_path.join(nix_ds_path).inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "//",
    "anchor": "//",
    "parts": ["//", "c", "d"],
  })
  @json.inspect(nix_ds_path.join(nix_rel_path).inspect(), content={
    "flavor": "posix",
    "drive": "",
    "root": "//",
    "anchor": "//",
    "parts": ["//", "c", "d", "c", "d"],
  })
}
