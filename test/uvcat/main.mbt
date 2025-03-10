///|
fn main {
  try {
    @uv.start!(fn(uv) {
      let args = @sys.get_cli_args()
      if args.length() != 2 {
        let name = args[0]
        println("Usage: \{name} <file>")
      }
      let source = uv.open!!(args[1], @uv.ReadOnly, 0)
      let target = uv.stdout()
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
  } catch {
    error => println("Error: \{error}")
  }
}
