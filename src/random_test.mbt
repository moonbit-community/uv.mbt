///|
test "random" {
  let uv = @uv.Loop::new()
  let buffer = Bytes::make(16, 0)
  let mut result = None
  let mut error = None
  uv.random(buffer[:], 0, fn(_, bytes) { result = Some(bytes) }, fn(_, errno) {
    error = Some(errno)
  })
  uv.run(Default)
  uv.stop()
  uv.close()
  assert_true(result is Some(result) && result.length() == buffer.length())
  raise_option(error)
}
