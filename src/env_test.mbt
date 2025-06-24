///|
test "os_environ" {
  let environ = @uv.os_environ()
  for name, value in environ {
    assert_eq(@uv.os_getenv(name), Some(value))
  }
}

///|
test "env" {
  let name = "UV_MBT_TEST"
  let value = "uv.mbt"
  @uv.os_setenv(name, value)
  assert_eq(@uv.os_getenv(name), Some(value))
  @uv.os_unsetenv(name)
  assert_eq(@uv.os_getenv(name), None)
}
