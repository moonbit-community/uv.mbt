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
async fn[T] async_suspend(f : ((T) -> Unit) -> Unit) -> T = "%async.suspend"

///|
async fn[T, E : Error] async_suspend_with_error(
  f : ((T) -> Unit, (E) -> Unit) -> Unit
) -> T raise E = "%async.suspend"

///|
fn async_run(f : async () -> Unit) -> Unit = "%async.run"

///|
let uv_ref : Ref[@uv.Loop?] = Ref::new(None)

///|
fn uv() -> @uv.Loop raise @uv.Errno {
  if uv_ref.val is Some(uv) {
    return uv
  }
  let uv = @uv.Loop::new()
  uv_ref.val = Some(uv)
  return uv
}

///|
pub fn[T] start(f : async () -> T raise) -> T raise {
  let uv = uv()
  let mut value = None
  let mut error = None
  async_run(fn() {
    try {
      value = Some(f())
    } catch {
      e => error = Some(e)
    }
    uv.walk(_.close(() => ()))
  })
  uv.run(Default)
  uv_ref.val = None
  uv.stop()
  uv.close()
  if error is Some(error) {
    raise error
  }
  guard value is Some(value)
  value
}

///|
priv struct Scope[E] {
  mut launched : Int
  mut canceled : Bool
  resolve : (Unit) -> Unit
  reject : (E) -> Unit
}

///|
fn[E] Scope::resolve(self : Scope[E]) -> Unit {
  self.launched -= 1
  if self.launched == 0 {
    (self.resolve)(())
  }
}

///|
fn[E] Scope::reject(self : Scope[E], error : E) -> Unit {
  self.canceled = true
  self.launched -= 1
  if self.launched == 0 {
    (self.reject)(error)
  }
}

///|
fn[E : Error] Scope::launch(
  self : Scope[E],
  f : async () -> Unit raise E
) -> Unit {
  if self.canceled {
    return
  }
  self.launched += 1
  async_run(fn() {
    try {
      f()
      self.resolve()
    } catch {
      e => self.reject(e)
    }
  })
}

///|
async fn[T, E : Error] Scope::new(
  f : async (Scope[E]) -> T raise E
) -> T raise E {
  let mut value = None
  async_suspend_with_error(fn(resolve, reject : (E) -> Unit) {
    let scope = Scope::{ launched: 0, canceled: false, resolve, reject }
    scope.launch(fn() { value = Some(f(scope)) })
  })
  guard value is Some(value)
  value
}

///|
pub fn args() -> Array[String] {
  @uv.args()
}
