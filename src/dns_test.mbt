///|
test "dns" {
  let uv = @uv.Loop::new!()
  let resolved = Set::new()
  uv.getaddrinfo!(
    fn(_, infos) {
      try {
        for info in infos {
          println("info.addr().ip_name!() = \{info.addr().ip_name!()}")
          resolved.add(info.addr().ip_name!())
        }
      } catch {
        e => println("Error: \{e}")
      }
    },
    fn(_, e) { println("Error: \{e}") },
    "localhost",
    "http",
  )
  uv.run!(Default)
  uv.stop()
  uv.close!()
  @json.inspect!(resolved, content=["::1", "127.0.0.1"])
}
