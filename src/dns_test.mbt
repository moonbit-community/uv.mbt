///|
test "dns/ipv4" {
  let uv = @uv.Loop::new()
  let resolved = []
  let mut error = None
  uv.getaddrinfo(
    fn(_, infos) {
      try {
        for info in infos {
          resolved.push(info.addr().ip_name())
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
      family=@uv.AddressFamily::inet(),
    ),
  )
  uv.run(Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
  resolved.dedup()
  @json.inspect(resolved, content=["127.0.0.1"])
}

///|
test "dns/ipv6" {
  let uv = @uv.Loop::new()
  let resolved = []
  let mut error = None
  uv.getaddrinfo(
    fn(_, infos) {
      try {
        for info in infos {
          resolved.push(info.addr().ip_name())
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
      family=@uv.AddressFamily::inet6(),
    ),
  )
  uv.run(Default)
  uv.close()
  if error is Some(error) {
    raise error
  }
  resolved.dedup()
  @json.inspect(resolved, content=["::1"])
}
