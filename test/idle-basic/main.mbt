///|
let counter : Ref[Int64] = Ref::new(0)

///|
fn wait_for_a_while(handle : @uv.Idle) -> Unit {
  counter.val += 1
  if counter.val >= 1000000 {
    ignore(@uv.idle_stop(handle))
  }
}

///|
fn main {
  let uv = @uv.loop_alloc()
  ignore(@uv.loop_init(uv))
  let idler = @uv.idle_alloc()
  ignore(@uv.idle_init(uv, idler))
  ignore(@uv.idle_start(idler, wait_for_a_while))
  println("Idling...")
  ignore(@uv.run(uv, @uv.RunMode::Default))
  ignore(@uv.close(@uv.idle_to_handle(idler), fn(_) {  }))
  ignore(@uv.loop_close(uv))
}
