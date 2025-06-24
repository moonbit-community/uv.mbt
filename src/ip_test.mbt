///|
test "ip4_addr" {
  ignore(@uv.ip4_addr("127.0.0.1", 8080))
}

///|
test "ip6_addr" {
  ignore(@uv.ip6_addr("::1", 8080))
}

///|
test "ip4_name" {
  let addr = @uv.ip4_addr("127.0.0.1", 8080)
  inspect(addr.ip_name(), content="127.0.0.1")
}

///|
test "ip6_name" {
  let addr = @uv.ip6_addr("::1", 8080)
  inspect(addr.ip_name(), content="::1")
}
