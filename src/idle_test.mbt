///|
let counter : Ref[Int64] = Ref::new(0)

///|
fn wait_for_a_while(handle : @uv.Idle) -> Unit {
  counter.val += 1
  if counter.val >= 100 {
    ignore(@uv.idle_stop(handle))
  }
}

///|
test {
  let uv = @uv.loop_alloc()
  @json.inspect!(@uv.loop_init(uv), content=0)
  let idler = @uv.idle_alloc()
  @json.inspect!(@uv.idle_init(uv, idler), content=0)
  @json.inspect!(@uv.idle_start(idler, wait_for_a_while), content=0)
  println("Idling...")
  @json.inspect!(@uv.run(uv, @uv.RunMode::Default), content=0)
  @uv.close(@uv.idle_to_handle(idler), fn(_) {  })
  @json.inspect!(@uv.loop_close(uv), content=-16)
}
