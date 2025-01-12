///|
fn main {
  try {
    @async.run!(fn(loop_) {
      let file = loop_.open!!("main.mbt", @uv.O_RDONLY, 0)
      read~: loop file.read!!()[:] {
        [] => break
        result =>
          write~: loop file.write!!(result) {
            [] => continue read~ file.read!!()[:] 
            remain => continue write~ file.write!!(remain)
          }
      }
      file.close!!()
    })
  } catch {
    @async.Errno(_) as errno => {
      println("Error: \{errno}")
    }
    error => println("Unknown error: \{error}")
  }
}
