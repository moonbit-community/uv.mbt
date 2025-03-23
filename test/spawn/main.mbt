///|
fn main {
  let uv = @uv.loop_alloc()
  @uv.loop_init(uv) |> ignore()
  fn on_exit(
    req : @uv.Process,
    exit_status : Int64,
    term_signal : Int
  ) -> Unit {
    println(
      "Process exited with status \{exit_status} and signal \{term_signal}",
    )
    @uv.process_close(req, fn(_) {
      @uv.stop(uv)
    })
  }

  let options = @uv.process_options_alloc()
  let args : FixedArray[Bytes?] = [
    Some(b"echo\x00"),
    Some(b"Hello, world!\x00"),
    None,
  ]
  @uv.process_options_set_args(options, args)
  @uv.process_options_set_file(options, b"echo\x00")
  let child_req = @uv.process_alloc()
  let result = @uv.spawn(uv, child_req, options, on_exit)
  if result != 0 {
    println("Error spawning process: \{result}")
  } else {
    println("Launched process with ID \{@uv.process_get_pid(child_req)}")
  }
  @uv.run(uv, @uv.RunMode::Default) |> ignore()
  @uv.loop_close(uv) |> ignore()
}
