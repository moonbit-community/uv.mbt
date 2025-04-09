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
  let uv = @uv.Loop::new!()
  let idler = @uv.idle_alloc()
  @json.inspect!(@uv.idle_init(uv, idler), content=0)
  @json.inspect!(@uv.idle_start(idler, wait_for_a_while), content=0)
  println("Idling...")
  uv.run!(@uv.RunMode::Default)
  @uv.stop(uv)
  let mut error = None
  @uv.close(@uv.idle_to_handle(idler), fn(_) {
    try {
      uv.close!()
    } catch {
      e => error = Some(e)
    }
  })
  if error is Some(error) {
    raise error
  }
}
