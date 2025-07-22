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
priv enum NameInst {
  Done
  Char(Charset)
  Jump(Int)
  Fork(Int, Int)
}

///|
priv type Prog Array[NameInst]

///|
fn Prog::new() -> Prog {
  Prog([])
}

///|
fn Prog::push(self : Prog, inst : NameInst) -> Unit {
  let Prog(prog) = self
  prog.push(inst)
}

///|
fn Prog::length(self : Prog) -> Int {
  let Prog(prog) = self
  prog.length()
}

///|
fn Prog::op_set(self : Prog, index : Int, inst : NameInst) -> Unit {
  let Prog(prog) = self
  prog[index] = inst
}

///|
impl ToJson for NameInst with to_json(self : NameInst) -> Json {
  match self {
    Done => { "done": true }
    Char(charset) => { "char": charset.to_json() }
    Jump(x) => { "jump": x }
    Fork(x, y) => { "fork": [x, y] }
  }
}

///|
fn Prog::exec(self : Prog, data : @string.View) -> Bool {
  let Prog(prog) = self
  let mut curr = @deque.new()
  let mut next = @deque.new()
  curr.push_back(0)
  let data_size = data.length()
  for sp in 0..=data_size {
    let mut np = sp + 1
    while curr.pop_front() is Some(pc) {
      match prog[pc] {
        Done => return true
        Char(charset) => {
          if sp == data_size {
            continue
          }
          let c1 = data.unsafe_charcode_at(sp)
          let char = if c1 is (0xD800..=0xDBFF) && sp + 1 < data_size {
            let c2 = data.unsafe_charcode_at(sp + 1)
            guard c2 is (0xDC00..=0xDFFF) else { continue }
            np = np + 1
            ((c1 - 0xD800) * 0x400 + (c2 - 0xDC00) + 0x10000).unsafe_to_char()
          } else {
            guard c1 is (0x0000..=0xD7FF | 0xE000..=0xFFFF) else { continue }
            c1.unsafe_to_char()
          }
          if charset.contains(char) {
            next.push_back(pc + 1)
          }
        }
        Jump(x) => curr.push_back(x)
        Fork(x, y) => {
          curr.push_back(x)
          curr.push_back(y)
        }
      }
    }
    let temp = curr
    curr = next
    next = temp
    next.clear()
  } else {
    false
  }
}

///|
test "char/a-z" {
  let prog : Prog = Prog::new()
  prog.push(Char(Charset(['a', 'z'])))
  prog.push(Done)
  let data = "a"
  assert_true(prog.exec(data))
}

///|
test "star" {
  let prog : Prog = Prog::new()
  prog.push(Fork(1, 3))
  prog.push(Char(Charset(['a', 'a'])))
  prog.push(Jump(0))
  prog.push(Done)
  assert_true(prog.exec(""))
  assert_true(prog.exec("a"))
  assert_true(prog.exec("aa"))
  assert_true(prog.exec("aaa"))
}

///|
priv enum PathInst {
  Done
  Name(Prog)
  Jump(Int)
  Fork(Int, Int)
}

///|
priv type Glob Array[PathInst]

///|
fn Glob::empty() -> Glob {
  Glob([])
}

///|
fn Glob::push(self : Glob, inst : PathInst) -> Unit {
  let Glob(prog) = self
  prog.push(inst)
}

///|
fn Glob::length(self : Glob) -> Int {
  let Glob(prog) = self
  prog.length()
}

///|
fn Glob::op_set(self : Glob, index : Int, inst : PathInst) -> Unit {
  let Glob(prog) = self
  prog[index] = inst
}

///|
fn Glob::exec(self : Glob, data : ArrayView[@string.View]) -> Bool {
  let Glob(prog) = self
  let mut curr = @deque.new()
  let mut next = @deque.new()
  curr.push_back(0)
  let data_size = data.length()
  for sp in 0..=data_size {
    while curr.pop_front() is Some(pc) {
      match prog[pc] {
        Done => return true
        Name(inst) => {
          if sp == data_size {
            continue
          }
          let name = data[sp]
          if name.length() == 0 {
            continue
          }
          if inst.exec(name) {
            next.push_back(pc + 1)
          }
        }
        Jump(x) => curr.push_back(x)
        Fork(x, y) => {
          curr.push_back(x)
          curr.push_back(y)
        }
      }
    }
    let temp = curr
    curr = next
    next = temp
    next.clear()
  } else {
    false
  }
}

///|
priv type Charset Array[Char]

///|
impl ToJson for Charset with to_json(self : Charset) -> Json {
  let Charset(charset) = self
  if charset is ['\u{0}', '\u{10FFFF}'] {
    return Json::string("wild")
  }
  let json_ranges = []
  for i = 0; i < charset.length(); i = i + 2 {
    let start = charset[i]
    let end = charset[i + 1]
    if start == end {
      json_ranges.push(start.to_json())
    } else if end == '\u{10FFFF}' {
      json_ranges.push([start.to_json(), "\\u{10FFFF}"])
    } else {
      json_ranges.push([start.to_json(), end.to_json()])
    }
  }
  if json_ranges is [string] {
    string
  } else {
    Json::array(json_ranges)
  }
}

///|
fn Charset::contains(self : Charset, ch : Char) -> Bool {
  let Charset(charset) = self
  let mut left = 0
  let mut right = charset.length() / 2 - 1
  while left <= right {
    let mid = (left + right) / 2
    let start = charset[mid * 2]
    let end = charset[mid * 2 + 1]
    if ch < start {
      right = mid - 1
    } else if ch > end {
      left = mid + 1
    } else {
      // ch is within the range [start, end]
      return true
    }
  }
  return false
}

///|
fn Charset::new() -> Charset {
  Charset([])
}

///|
fn Charset::wild() -> Charset {
  Charset(['\u{0}', '\u{10FFFF}'])
}

///|
fn Charset::push_char(self : Charset, char : Char) -> Unit {
  let Charset(charset) = self
  charset.push(char)
  charset.push(char)
}

///|
fn Charset::push_range(self : Charset, start : Char, end : Char) -> Unit {
  let Charset(charset) = self
  charset.push(start)
  charset.push(end)
}

///|
priv suberror ParseError {
  NonRelativePattern
  UnterminatedCharacterClass(@string.View)
  UnexpectedRange(@string.View)
  InvalidRange(@string.View)
}

///|
fn Charset::parse(
  self : Charset,
  pattern : @string.View,
) -> @string.View raise ParseError {
  let start = pattern
  let mut last_char = None
  let pattern = match pattern {
    [char, .. pattern] => {
      last_char = Some(char)
      pattern
    }
    [] => raise ParseError::UnterminatedCharacterClass(start)
  }
  loop pattern {
    [']', .. pattern] => {
      if last_char is Some(last_char) {
        self.push_char(last_char)
      }
      return pattern
    }
    ['-', ']', .. pattern] => {
      if last_char is Some(last_char) {
        self.push_char(last_char)
      }
      self.push_char('-')
      return pattern
    }
    ['-', char, .. pattern] as original_pattern => {
      guard last_char is Some(last_char) else {
        raise ParseError::UnexpectedRange(original_pattern)
      }
      if last_char > char {
        raise ParseError::InvalidRange(original_pattern)
      }
      self.push_range(last_char, char)
      continue pattern
    }
    [char, .. pattern] => {
      if last_char is Some(last_char) {
        self.push_char(last_char)
      }
      last_char = Some(char)
      continue pattern
    }
    [] => raise ParseError::UnterminatedCharacterClass(start)
  }
}

///|
fn Charset::simplify(self : Charset) -> Charset {
  let Charset(charset) = self

  // Convert chars to array of ranges (start, end) pairs
  let ranges = []
  for i = 0; i < charset.length(); i = i + 2 {
    let start = charset[i]
    let end = charset[i + 1]
    ranges.push((start, end))
  }

  // Sort ranges by start character
  ranges.sort_by_key(range => range.0)

  // Simplify ranges by merging overlapping or adjacent ranges
  let simplified = []
  let mut current_start = '\u{0}'
  let mut current_end = '\u{0}'
  if ranges.length() > 0 {
    current_start = ranges[0].0
    current_end = ranges[0].1
    for range in ranges[1:] {
      let (next_start, next_end) = range

      // Check if ranges overlap or are adjacent
      if next_start <= (current_end.to_int() + 1).unsafe_to_char() {
        // Merge ranges
        current_end = if current_end > next_end {
          current_end
        } else {
          next_end
        }
      } else {
        // Add current range to result and start new range
        simplified.push(current_start)
        simplified.push(current_end)
        current_start = next_start
        current_end = next_end
      }
    }

    // Add the last range
    simplified.push(current_start)
    simplified.push(current_end)
  }
  Charset(simplified)
}

///|
fn Charset::complement(self : Charset) -> Charset {
  // First simplify the input ranges
  let Charset(simplified) = self.simplify()
  if simplified.length() == 0 {
    // Empty character class, complement is everything
    return Charset::wild()
  }
  let complement = []
  let min_char = '\u{0}'
  let max_char = '\u{10FFFF}'

  // Add range before first range if it doesn't start at minimum
  if simplified[0] > min_char {
    complement.push(min_char)
    complement.push((simplified[0].to_int() - 1).unsafe_to_char())
  }

  // Add gaps between ranges
  for i = 0; i < simplified.length() / 2 - 1; i = i + 1 {
    let current_end = simplified[i * 2 + 1]
    let next_start = simplified[(i + 1) * 2]
    let gap_start = (current_end.to_int() + 1).unsafe_to_char()
    let gap_end = (next_start.to_int() - 1).unsafe_to_char()
    if gap_start <= gap_end {
      complement.push(gap_start)
      complement.push(gap_end)
    }
  }

  // Add range after last range if it doesn't end at maximum
  let last_end = simplified[simplified.length() - 1]
  if last_end < max_char {
    complement.push((last_end.to_int() + 1).unsafe_to_char())
    complement.push(max_char)
  }
  Charset(complement)
}

///|
fn Glob::parse(pattern : @string.View) -> Prog raise ParseError {
  let inst = Prog::new()
  loop pattern {
    ['?', .. pattern] => {
      inst.push(Char(Charset::wild()))
      continue pattern
    }
    ['*', .. pattern] => {
      let fork_inst = inst.length()
      inst.push(Fork(-1, -1))
      inst.push(Char(Charset::wild()))
      inst.push(Jump(fork_inst))
      inst[fork_inst] = Fork(fork_inst + 1, inst.length())
      continue pattern
    }
    ['[', '!', .. pattern] => {
      let charset = Charset::new()
      let pattern = charset.parse(pattern)
      inst.push(Char(charset.complement()))
      continue pattern
    }
    ['[', .. pattern] => {
      let charset = Charset::new()
      let pattern = charset.parse(pattern)
      inst.push(Char(charset.simplify()))
      continue pattern
    }
    [char, .. pattern] => {
      let charset = Charset::new()
      charset.push_char(char)
      inst.push(Char(charset))
      continue pattern
    }
    [] => {
      inst.push(Done)
      inst
    }
  }
}

///|
fn Glob::new(path : @string.View) -> Glob raise ParseError {
  let path = ToPath::to_path(path)
  if path.anchor() != "" {
    raise ParseError::NonRelativePattern
  }
  let glob = Glob::empty()
  for part in path.parts() {
    if part is "**" {
      let fork_inst = glob.length()
      glob.push(Fork(-1, -1))
      let prog = Prog::new()
      prog.push(Done)
      glob.push(Name(prog))
      glob.push(Jump(fork_inst))
      glob[fork_inst] = Fork(fork_inst + 1, glob.length())
    } else {
      glob.push(Name(Glob::parse(part)))
    }
  }
  glob.push(Done)
  glob
}

///|
fn Glob::matches(self : Glob, path : Path) -> Bool raise ParseError {
  if path.anchor() != "" {
    raise ParseError::NonRelativePattern
  }
  self.exec(path.parts)
}

///|
test "Glob::parse" {
  let Prog(prog) = Glob::parse("a[bcd]*e?f")
  @json.inspect(prog, content=[
    { "char": "a" },
    { "char": ["b", "d"] },
    { "fork": [3, 5] },
    { "char": "wild" },
    { "jump": 2 },
    { "char": "e" },
    { "char": "wild" },
    { "char": "f" },
    { "done": true },
  ])
}

///|
test "Glob::parse/range" {
  let Prog(prog) = Glob::parse("[a-zA-Z]")
  @json.inspect(prog, content=[
    { "char": [["A", "Z"], ["a", "z"]] },
    { "done": true },
  ])
  let Prog(prog) = Glob::parse("[a-zA-Z0-]")
  @json.inspect(prog, content=[
    { "char": ["-", "0", ["A", "Z"], ["a", "z"]] },
    { "done": true },
  ])
  let Prog(prog) = Glob::parse("[-a-zA-Z]")
  @json.inspect(prog, content=[
    { "char": ["-", ["A", "Z"], ["a", "z"]] },
    { "done": true },
  ])
  let Prog(prog) = Glob::parse("[--0]")
  @json.inspect(prog, content=[{ "char": ["-", "0"] }, { "done": true }])
  let Prog(prog) = Glob::parse("[][!]")
  @json.inspect(prog, content=[{ "char": ["!", "[", "]"] }, { "done": true }])
  let Prog(prog) = Glob::parse("[]-]")
  @json.inspect(prog, content=[{ "char": ["-", "]"] }, { "done": true }])
}

///|
test "Glob::parse/complement" {
  let Prog(prog) = Glob::parse("[!]a-]")
  guard prog[0] is Char(charset)
  @json.inspect(charset.complement(), content=["-", "]", "a"])
}

///|
test "Prog::exec" {
  let glob = Glob::parse("a[bcd]e?f*")
  assert_true(glob.exec("abexfg"))
  assert_true(glob.exec("acexf"))
  assert_true(glob.exec("adezf"))
  assert_false(glob.exec("aefg"))
  assert_false(glob.exec("abefg"))
  assert_false(glob.exec("aefgxyz"))
}

///|
test "Glob::matches" {
  let glob = Glob::new("a*/b/c[def]")
  assert_false(glob.matches(Path::new(["a", "b", "cc"])))
  assert_true(glob.matches(Path::new(["a", "b", "cd"])))
  assert_true(glob.matches(Path::new(["a", "b", "ce"])))
  assert_true(glob.matches(Path::new(["a", "b", "cf"])))
  assert_false(glob.matches(Path::new(["a", "b", "cg"])))
  assert_true(glob.matches(Path::new(["aa", "b", "cd"])))
  assert_true(glob.matches(Path::new(["aaa", "b", "cd"])))
}

///|
test "Glob::matches/recursive" {
  let glob = Glob::new("a/**/*c")
  assert_true(glob.matches(Path::new(["a", "c"])))
  assert_true(glob.matches(Path::new(["a", "b", "cc"])))
  assert_true(glob.matches(Path::new(["a", "b", "b", "ccc"])))
}

///|
pub fn Path::glob(self : Path, pattern : @string.View) -> Iter[Path] raise {
  let glob = Glob::new(pattern)
  fn(yield_) {
    self.walk().each(fn(path) { if glob.matches(path) { yield_(path) } })
  }
}
