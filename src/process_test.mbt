///|
test "spawn" {
  let uv = @uv.Loop::new!()
  let mut test_exit_status = None
  let mut test_term_signal = None
  fn on_exit(
    child : @uv.Process,
    exit_status : Int64,
    term_signal : Int
  ) -> Unit {
    test_exit_status = Some(exit_status)
    test_term_signal = Some(term_signal)
    child.close(fn(_) { uv.stop() })
  }

  let stdio = [
    @uv.StdioContainer::ignore(),
    @uv.StdioContainer::inherit_fd(@uv.STDOUT),
    @uv.StdioContainer::inherit_fd(@uv.STDERR),
  ]
  let options = @uv.ProcessOptions::new("moon", ["check"], stdio~, fn(
    child,
    exit_status,
    term_signal
  ) {
    on_exit(child, exit_status, term_signal)
  })
  let _ = uv.spawn!(options)
  @uv.run!(uv, @uv.RunMode::Default)
  inspect!(test_exit_status, content="Some(0)")
  inspect!(test_term_signal, content="Some(0)")
  uv.close!()
}
