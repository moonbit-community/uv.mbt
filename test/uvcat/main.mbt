///|
fn main {
  let args = @uv.args()
  let uv = @uv.loop_alloc()
  ignore(@uv.loop_init(uv))
  let open_req = @uv.fs_alloc()
  let read_req = @uv.fs_alloc()
  let write_req = @uv.fs_alloc()
  let buffer : Bytes = Bytes::make(1024, 0)
  let iov = @uv.buf_alloc()
  fn on_close(_) {
    @uv.fs_req_cleanup(open_req)
    @uv.fs_req_cleanup(read_req)
    @uv.fs_req_cleanup(write_req)
  }

  fn on_write(req : @uv.Fs) -> Unit {
    let result = @uv.fs_get_result(req)
    if result < 0 {
      println("Write error: \{@uv.strerror(result.to_int())}")
    } else {
      @uv.fs_read(
        uv,
        read_req,
        @uv.fs_get_result(open_req).to_int(),
        [iov],
        -1,
        on_read,
      )
      |> ignore()
    }
  }

  fn on_read(req : @uv.Fs) -> Unit {
    let result = @uv.fs_get_result(req)
    if result < 0 {
      println("Read error: \{@uv.strerror(result.to_int())}")
    } else if result == 0 {
      let close_req = @uv.fs_alloc()
      @uv.fs_close(
        uv,
        close_req,
        @uv.fs_get_result(open_req).to_int(),
        on_close,
      )
      |> ignore()
    } else if result > 0 {
      @uv.buf_set_len(iov, result.reinterpret_as_uint64())
      @uv.fs_write(uv, write_req, 1, [iov], -1, on_write) |> ignore()
    }
  }

  fn on_open(req : @uv.Fs) -> Unit {
    guard physical_equal(req, open_req)
    let result = @uv.fs_get_result(req).to_int()
    if result >= 0 {
      let file : @uv.File = result
      @uv.buf_init(iov, buffer, 0, buffer.length())
      @uv.fs_read(uv, read_req, file, [iov], -1, on_read) |> ignore()
    } else {
      println("Error opening file: \{@uv.strerror(result)}")
    }
  }

  @uv.fs_open(uv, open_req, [..args[1], b'\x00'], ReadOnly, 0, on_open)
  |> ignore()
  @uv.run(uv, @uv.RunMode::Default) |> ignore()
}
