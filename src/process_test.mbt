///|
test "spawn" {
  let uv = @uv.loop_alloc()
  @json.inspect!(@uv.loop_init(uv), content=0)
  let mut test_exit_status = None
  let mut test_term_signal = None
  fn on_exit(
    req : @uv.Process,
    exit_status : Int64,
    term_signal : Int
  ) -> Unit {
    test_exit_status = Some(exit_status)
    test_term_signal = Some(term_signal)
    @uv.process_close(req, fn(_) { @uv.stop(uv) })
  }

  let options = @uv.process_options_alloc()
  let args : FixedArray[Bytes?] = [
    Some(b"echo\x00"),
    Some(b"test-dir\x00"),
    None,
  ]
  @uv.process_options_set_args(options, args)
  @uv.process_options_set_file(options, b"echo\x00")
  let child_req = @uv.process_alloc()
  @json.inspect!(@uv.spawn(uv, child_req, options, on_exit), content=0)
  @json.inspect!(@uv.run(uv, @uv.RunMode::Default), content=0)
  inspect!(test_exit_status, content="Some(0)")
  inspect!(test_term_signal, content="Some(0)")
  @json.inspect!(@uv.loop_close(uv), content=0)
}
