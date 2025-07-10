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
priv type Context

///|
priv struct Routine {
  id : Int
  parent : Routine?
  context : Context
}

///|
#borrow(from, to)
extern "c" fn mygo_context_shift(from : Context, to : Context) = "mygo_context_shift"

///|
extern "c" fn mygo_context_make() -> Context = "mygo_context_make"

///|
extern "c" fn mygo_context_reset(context : Context, f : () -> Unit) -> Unit = "mygo_context_reset"

///|
let id_gen : Ref[Int] = Ref::new(0)

///|
fn next_id() -> Int {
  let id = id_gen.val
  id_gen.val += 1
  id
}

///|
let context : Ref[Routine] = Ref::new({
  id: next_id(),
  parent: None,
  context: mygo_context_make(),
})

///|
pub fn run(f : () -> Unit) -> Unit {
  let parent = context.val
  let child = {
    id: next_id(),
    parent: Some(parent),
    context: mygo_context_make(),
  }
  mygo_context_reset(parent.context, () => {
    context.val = child
    f()
    context.val = parent
  })
}

///|
pub fn[T, E : Error] suspend(
  f : ((T) -> Unit, (E) -> Unit) -> Unit,
) -> T raise E {
  guard context.val.parent is Some(parent) else {
    println("Cannot suspend without a parent context")
    panic()
  }
  let child = {
    id: next_id(),
    parent: Some(parent),
    context: mygo_context_make(),
  }
  let mut result : T? = None
  let mut error : E? = None
  f(
    (r : T) => {
      result = Some(r)
      let parent = context.val
      context.val = child
      mygo_context_shift(parent.context, child.context)
    },
    (e : E) => {
      error = Some(e)
      let parent = context.val
      context.val = child
      mygo_context_shift(parent.context, child.context)
    },
  )
  context.val = parent
  mygo_context_shift(child.context, parent.context)
  if error is Some(e) {
    raise e
  }
  result.unwrap()
}

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
pub fn[T] start(f : () -> T raise) -> T raise {
  let uv = uv()
  let mut value = None
  let mut error = None
  run(fn() {
    try {
      value = Some(f())
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
  guard value is Some(value)
  value
}
