///|
fn main {
  try {
    let uv = @uv.Loop::new!()
    let options = @uv.ProcessOptions::new(
      "mkdir",
      ["mkdir", "test-dir"],
      fn(process, exit_status, term_signal) {
        println(
          "Process exited with status \{exit_status} and signal \{term_signal}",
        )
        process.close(fn(_) {  })
      },
    )
    let process = uv.spawn!(options)
    println("Launched process with ID \{(process).pid()}")
    uv.run!(Default)
    uv.stop()
    uv.close!()
  } catch {
    error => println("Error: \{error}")
  }
}
