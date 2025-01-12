///|
let counter : Ref[Int] = @ref.new(0)

///|
fn wait_for_a_while(handle : @uv.Idle) -> Unit {
  counter.val += 1
  if counter.val >= 1000 {
    @uv.idle_stop(handle) |> ignore
  }
}

///|
fn run_async(f :  async() -> Unit) -> Unit = "%async.run"

///|
fn main {
  try {
    let loop_ = @uv.Loop::default()
    let idler = @uv.Idle::new!(loop_)
    run_async(fn() {
      try {
        while counter.val < 1000 {
          idler.start!!()
          counter.val += 1
          println("Counter: " + Show::to_string(counter.val))
          idler.stop!()
        }
      } catch {
        err => println("Error: " + Show::to_string(err))
      }
    })
    println("Idling...")
    loop_.run!(Default) |> ignore
    loop_.drop!()
  } catch {
    err => println("Error: " + Show::to_string(err))
  }
}
