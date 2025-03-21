fn on_exit(req : @uv.Process, exit_status : Int, term_signal : Int) -> Unit {
  println("Process exited with status \{exit_status} and signal \{term_signal}")
  @uv.close(@uv.process_to_handle(req), fn(_) {  })
}

///|
fn main {
  let uv = @uv.loop_alloc()
  ignore(@uv.loop_init(uv))
  let options = @uv.process_options_alloc()
  let args : FixedArray[Bytes?] = [
    Some(b"mkdir\x00"),
    Some(b"test-dir\x00"),
    None
  ]
  @uv.process_options_set_args(options, args)
  @uv.process_options_set_file(options, b"mkdir\x00")
  let child_req = @uv.process_alloc()
  let result = @uv.spawn(uv, child_req, options, on_exit)
  if result != 0 {
    println("Error spawning process: \{result}")
  } else {
    println("Launched process with ID \{@uv.process_get_pid(child_req)}")
  }
  ignore(@uv.run(uv, @uv.RunMode::Default))
}
