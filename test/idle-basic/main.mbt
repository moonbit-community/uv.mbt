///|
fn main {
  try {
    let uv = @uv.Loop::new!()
    let idler = @uv.Idle::new!(uv)
    let mut counter = 0
    fn wait_for_a_while(handle : @uv.Idle) -> Unit {
      try {
        counter += 1
        if counter >= 2 {
          handle.stop!()
          handle.close(fn(_) {  })
        }
      } catch {
        error => println("Error: \{error}")
      }
    }

    idler.start!(fn(idle) { wait_for_a_while(idle) })
    println("Idling...")
    uv.run!(@uv.RunMode::Default)
    uv.stop()
    uv.close!()
  } catch {
    error => println("Error: \{error}")
  }
}
