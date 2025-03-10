///|
fn main {
  try {
    @uv.start!(fn(uv) {
      let idle = uv.idle!()
      let mut counter = 0
      @uv.spawn(fn() {
        while true {
          idle.start!!()
          counter += 1
          if counter >= 1000 {
            break
          }
        }
      })
      println("Idling...\n")
    })
  } catch {
    error => println("Error: \{error}")
  }
}
