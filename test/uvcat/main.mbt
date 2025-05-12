///|
fn main {
  try {
    let args = @uv.args()
    fn do_read(uv : @uv.Loop, file : @uv.File, bytes : Bytes) -> Unit {
      try {
        uv.fs_read!(
          file,
          [bytes[:]],
          fn(_, count) { do_write(uv, file, bytes, 0, count) },
          fn(_, error) { println("Error reading file: \{error}") },
        )
      } catch {
        error => println("Error reading file: \{error}")
      }
    }

    fn do_write(
      uv : @uv.Loop,
      file : @uv.File,
      bytes : Bytes,
      start : Int,
      count : Int
    ) -> Unit {
      try {
        if count == 0 {
          uv.fs_close!(file, fn(_) {  })
        } else {
          uv.fs_write!(
            @uv.stdout(),
            [bytes[start:start + count]],
            fn(_, write_count) {
              if write_count < count {
                do_write(
                  uv,
                  file,
                  bytes,
                  start + write_count,
                  count - write_count,
                )
              } else {
                do_read(uv, file, bytes)
              }
            },
            fn(_, error) { println("Write error: \{error}") },
          )
        }
      } catch {
        error => println("Write error: \{error}")
      }
    }

    let uv = @uv.Loop::new!()
    uv.fs_open!(
      args[1],
      @uv.OpenFlags::read(),
      0,
      fn(_, file) { do_read(uv, file, Bytes::make(1024, 0)) },
      fn(_, error) { println("Error opening file: \{error}") },
    )
    uv.run!(Default)
    uv.stop()
    uv.close!()
  } catch {
    error => println("Error: \{error}")
  }
}
