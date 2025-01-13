///|
let counter : Ref[Int] = @ref.new(0)

///|
fn wait_for_a_while(idle : @uv.Idle) -> Unit {
  counter.val += 1
  if counter.val >= 1000 {
    @uv.idle_stop(idle) |> ignore
  }
}

///|
fn main {
  let loop_ = @uv.default_loop()
  let idle = @uv.idle_alloc()
  @uv.idle_init(loop_, idle) |> ignore
  @uv.idle_start(idle, wait_for_a_while) |> ignore
  println("Idling...\n")
  @uv.run(loop_, @uv.UV_RUN_DEFAULT) |> ignore
  @uv.loop_close(loop_) |> ignore
}
