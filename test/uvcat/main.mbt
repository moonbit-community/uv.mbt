///|
fn main {
  try {
    let uv = @uv.Loop::new!()
    @uv.async_run(fn() {
      let args = @async.args()
      if args.length() != 2 {
        let name = args[0]
        let name = @encoding.decoder(UTF8).decode!(name)
        println("Usage: \{name} <file>")
      }
      let source = uv.open!!(args[1], @async.ReadOnly, 0)
      let target = loop_.stdout()
      read~: loop source.read!!() {
        [] => break
        result =>
          write~: loop target.write!!(result) {
            [] => continue read~ source.read!!()
            remain => continue write~ target.write!!(remain)
          }
      }
      source.close!!()
    })
    @uv.run!(@uv.Loop::new!(), @uv.RunMode::Default);
  } catch {
    @uv.Errno(_) as errno => println("Error: \{errno}")
    error => println("Unknown error: \{error}")
  }
}
