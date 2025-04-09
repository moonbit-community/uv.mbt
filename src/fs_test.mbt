///|
test "cat" {
  let uv = @uv.Loop::new!()
  let open_req = @uv.fs_alloc()
  let mut open_error = None
  let read_req = @uv.fs_alloc()
  let mut read_error = None
  let write_req = @uv.fs_alloc()
  let mut write_error = None
  let buffer : Bytes = Bytes::make(1024, 0)
  let iov = @uv.buf_alloc()
  @uv.buf_init(iov, buffer, buffer.length())
  fn on_close(close_req) {
    @uv.fs_req_cleanup(open_req)
    @uv.fs_req_cleanup(read_req)
    @uv.fs_req_cleanup(write_req)
    @uv.fs_req_cleanup(close_req)
    @uv.stop(uv)
  }

  fn on_write(req : @uv.Fs) -> Unit {
    try {
      let result = @uv.fs_get_result(req)
      if result < 0 {
        fail!("Write error: \{@uv.strerror(result.to_int())}")
      } else {
        @uv.fs_read(
          uv,
          read_req,
          @uv.fs_get_result(open_req).to_int(),
          [iov],
          -1,
          fn(req) { on_read(req) },
        )
        |> assert_eq!(0)
      }
    } catch {
      error => write_error = Some(error)
    }
  }

  fn on_read(req : @uv.Fs) -> Unit {
    try {
      let result = @uv.fs_get_result(req)
      if result < 0 {
        fail!("Read error: \{@uv.strerror(result.to_int())}")
      } else if result == 0 {
        let close_req = @uv.fs_alloc()
        @uv.fs_close(uv, close_req, @uv.fs_get_result(open_req).to_int(), fn(
          req
        ) {
          on_close(req)
        })
        |> assert_eq!(0)
      } else if result > 0 {
        @uv.buf_set_len(iov, result.reinterpret_as_uint64())
        @uv.fs_write(uv, write_req, 1, [iov], -1, fn(req) { on_write(req) })
        |> assert_eq!(0)
      }
    } catch {
      error => read_error = Some(error)
    }
  }

  fn on_open(req : @uv.Fs) -> Unit {
    try {
      guard physical_equal(req, open_req)
      let result = @uv.fs_get_result(req).to_int()
      if result >= 0 {
        let file : @uv.File = result
        assert_eq!(
          @uv.fs_read(uv, read_req, file, [iov], -1, fn(req) { on_read(req) }),
          0,
        )
      } else {
        fail!("Error opening file: \{@uv.strerror(result)}")
      }
    } catch {
      error => open_error = Some(error)
    }
  }

  @json.inspect!(
    @uv.fs_open(uv, open_req, [..b"README.md", b'\x00'], ReadOnly, 0, fn(req) {
      on_open(req)
    }),
    content=0,
  )
  uv.run!(@uv.RunMode::Default)
  uv.close!()
  if open_error is Some(error) {
    raise error
  }
  if read_error is Some(error) {
    raise error
  }
  if write_error is Some(error) {
    raise error
  }
}
