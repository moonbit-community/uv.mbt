///|
fn main {
  try {
    let uv = @uv.Loop::new!()
    @uv.run!(uv, @uv.RunMode::Default, fn() {
      try {
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
      } catch {
        @uv.Errno(_) as errno => println("Error: \{errno}")
      }
    })
  } catch {
    @uv.Errno(_) as errno => println("Error: \{errno}")
  }
}
