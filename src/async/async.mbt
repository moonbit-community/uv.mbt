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
priv trait Cancel {
  cancel() -> Self
}

///|
impl Cancel for @uv.Errno with cancel() -> @uv.Errno {
  @uv.ECANCELED
}

///|
impl Cancel for Error with cancel() -> Error {
  @uv.ECANCELED
}

///|
async fn[T, E : Error + Cancel] suspend_with_error(
  f : ((T) -> Unit, (E) -> Unit) -> Unit
) -> T raise E {
  let scope = active_scope.val
  if scope is Some(scope) && scope.canceled {
    raise E::cancel()
  }
  try {
    let value = async_suspend_with_error(f)
    active_scope.val = scope
    if scope is Some(scope) && scope.canceled {
      raise E::cancel()
    }
    value
  } catch {
    error => {
      active_scope.val = scope
      raise error
    }
  }
}

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
pub suberror Dead

///|
pub fn[T] start(f : async () -> T raise) -> T raise {
  let uv = uv()
  let mut value = None
  let mut error = None
  async_run(fn() {
    try {
      value = Some(scope(f))
    } catch {
      e => error = Some(e)
    }
    uv.walk(_.close(() => ()))
  })
  uv.run(Default)
  uv_ref.val = None
  uv.close()
  if error is Some(error) {
    raise error
  }
  guard value is Some(value) else { raise Dead }
  value
}

///|
let id_gen : Ref[Int] = Ref::new(0)

///|
priv struct Scope {
  id : Id
  parent : Scope?
  scopes : Map[Id, async () -> Unit raise]
  mut launched : Int
  mut canceled : Bool
  mut accept : (Unit) -> Unit
  mut reject : (Error) -> Unit
  errors : Array[Error]
}

///|
fn Scope::ignore_accept(_ : Unit) -> Unit {
  // This is a no-op function use to untie the reference cycle
  // between the scope and its accept/reject callbacks.
}

///|
fn Scope::ignore_reject(_ : Error) -> Unit {
  // This is a no-op function use to untie the reference cycle
  // between the scope and its accept/reject callbacks.
}

///|
let active_scope : Ref[Scope?] = Ref::new(None)

///|
pub suberror MultiError Array[Error] derive(Show)

///|
fn MultiError::flatten(errors : Array[Error]) -> Array[Error] {
  let flatten = []
  for error in errors {
    if error is MultiError(multi_errors) {
      flatten.append(MultiError::flatten(multi_errors))
    } else {
      flatten.push(error)
    }
  }
  flatten
}

///|
priv type Id Int derive(Show, Hash, Eq)

///|
fn Id::new() -> Id {
  let id = id_gen.val
  id_gen.val += 1
  id
}

///|
fn Scope::accept(self : Scope) -> Unit {
  self.launched -= 1
  if self.launched == 0 {
    if self.parent is Some(parent) {
      parent.scopes.remove(self.id)
    }
    let accept = self.accept
    let reject = self.reject
    self.accept = Scope::ignore_accept
    self.reject = Scope::ignore_reject
    match MultiError::flatten(self.errors) {
      [] => accept(())
      [error] => reject(error)
      errors => reject(MultiError(errors))
    }
  }
}

///|
async fn Scope::reject(self : Scope, error : Error) -> Unit {
  self.cancel()
  self.errors.push(error)
  self.accept()
}

///|
fn Scope::launch(self : Scope, f : async () -> Unit raise) -> Unit {
  if self.canceled {
    return
  }
  self.launched += 1
  async_run(() => try {
    f()
    self.accept()
  } catch {
    e => self.reject(e)
  })
}

///|
async fn Scope::cancel(self : Scope) -> Unit {
  if self.canceled {
    return
  }
  self.canceled = true
  let children = []
  for _, child in self.scopes {
    children.push(child)
  }
  for i in 0..<children.length() {
    children[i]() catch {
      error => self.errors.push(error)
    }
  }
}

///|
pub fn launch(f : async () -> Unit raise) -> Unit raise {
  let self = active_scope.val
  guard self is Some(self) else {
    raise ValueError::NotFound("No active scope")
  }
  self.launch(() => scope(f))
}

///|
pub fn cancel() -> Unit raise {
  raise @uv.ECANCELED
}

///|
pub async fn[T] scope(f : async () -> T raise) -> T raise {
  let parent = active_scope.val
  if parent is Some(parent) && parent.canceled {
    raise @uv.ECANCELED
  }
  let mut value = None
  suspend_with_error((accept, reject) => {
    let scope = Scope::new(parent, accept, reject)
    active_scope.val = Some(scope)
    scope.launch(() => value = Some(f()))
    active_scope.val = parent
  })
  guard value is Some(value) else { raise Dead }
  value
}

///|
fn Scope::new(
  parent : Scope?,
  accept : (Unit) -> Unit,
  reject : (Error) -> Unit
) -> Scope {
  let id = Id::new()
  let scope = Scope::{
    id,
    parent,
    scopes: Map::new(),
    launched: 0,
    canceled: false,
    accept,
    reject,
    errors: [],
  }
  if parent is Some(parent) {
    parent.scopes[id] = () => scope.cancel()
  }
  scope
}

///|
pub fn args() -> Array[String] {
  @uv.args()
}
