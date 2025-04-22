///|
test "dns" {
  let uv = @uv.Loop::new!()
  let resolved = []
  let mut error = None
  uv.getaddrinfo!(
    fn(_, infos) {
      try {
        for info in infos {
          resolved.push(info.addr().ip_name!())
        }
      } catch {
        e => error = Some(e)
      }
    },
    fn(_, e) { error = Some(e) },
    "localhost",
    "http",
    hints=@uv.AddrInfoHints::new(
      protocol=@uv.Protocol::tcp(),
      flags=@uv.AddrInfoFlags::new(canonname=true),
    ),
  )
  uv.run!(Default)
  uv.stop()
  uv.close!()
  raise_option!(error)
  @json.inspect!(resolved, content=["::1", "127.0.0.1"])
}
