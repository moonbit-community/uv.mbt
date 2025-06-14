///|
fn main {
  try {
    let uv = @uv.Loop::new()
    let tty = @uv.Tty::new(uv, @uv.stdout())
    let bytes : Bytes = "\x1b[31mHello, World!\x1b[0m"
    tty.write([bytes[:]], fn(_) {  }, fn(_, error) {
      println("Write error: \{error}")
    })
    uv.run(Default)
    uv.stop()
    uv.close()
  } catch {
    error => println("Error: \{error}")
  }
}
