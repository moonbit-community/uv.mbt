///|
fn main {
  let uv = @uv.loop_alloc()
  @uv.loop_init(uv) |> ignore()
  let tty = @uv.tty_alloc()
  @uv.tty_init(uv, tty, @uv.STDOUT) |> ignore()
  let write = @uv.write_alloc()
  let buf = @uv.buf_alloc()
  let bytes : Bytes = "\x1b[31mHello, World!\x1b[0m"
  @uv.buf_init(buf, bytes, bytes.length())
  fn on_write(_ : @uv.Write, status : Int) {
    if status < 0 {
      println("Write error: \{@uv.strerror(status)}")
    }
  }

  @uv.write(write, tty.to_stream(), [buf], on_write) |> ignore()
  @uv.run(uv, @uv.RunMode::Default) |> ignore()
  @uv.loop_close(uv) |> ignore()
}
