///|
test "is_readable" {
  let uv = @uv.Loop::new!()
  let stream = @uv.Pipe::new!(uv, ipc=false)
  @json.inspect!(stream.is_readable(), content=false)
  @json.inspect!(stream.is_writable(), content=false)
  stream.close(fn(_) { })
  uv.run!(Default)
  uv.stop()
  uv.close!()
}
