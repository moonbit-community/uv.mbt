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
#autofill_callsite(loc)
pub fn t(x : Bool, msg? : String, loc~ : SourceLoc) -> Unit raise {
  if !x {
    let fail_msg = match msg {
      Some(msg) => msg
      None => "`\{x}` is not true"
    }
    fail(fail_msg, loc~)
  }
}

///|
#autofill_callsite(loc)
pub fn n(x : Bool, msg? : String, loc~ : SourceLoc) -> Unit raise {
  if x {
    let fail_msg = match msg {
      Some(msg) => msg
      None => "`\{x}` is not true"
    }
    fail(fail_msg, loc~)
  }
}

///|
fn[T : Show] debug_string(t : T) -> String {
  let buf = StringBuilder::new(size_hint=50)
  t.output(buf)
  buf.to_string()
}

///|
#autofill_callsite(loc)
pub fn[T : Eq + Show] eq(
  a : T,
  b : T,
  msg? : String,
  loc~ : SourceLoc,
) -> Unit raise {
  if a != b {
    let fail_msg = match msg {
      Some(msg) => msg
      None => "`\{debug_string(a)} != \{debug_string(b)}`"
    }
    fail(fail_msg, loc~)
  }
}
