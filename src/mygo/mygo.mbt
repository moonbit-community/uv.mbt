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
  println("Running mygo context with id \{context.val.id}")
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
  println("reset finished: \{parent.id}")
}

///|
pub fn[T, E : Error] suspend(
  f : ((T) -> Unit, (E) -> Unit) -> Unit
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
      println("mygo_context_switch: \{parent.id} -> \{child.id}")
      mygo_context_shift(parent.context, child.context)
    },
    (e : E) => {
      error = Some(e)
      let parent = context.val
      context.val = child
      println("mygo_context_switch: \{parent.id} -> \{child.id}")
      mygo_context_shift(parent.context, child.context)
    },
  )
  context.val = parent
  println("mygo_context_switch: \{child.id} -> \{parent.id}")
  mygo_context_shift(child.context, parent.context)
  println("mygo_context_switch: returned from \{parent.id}")
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
