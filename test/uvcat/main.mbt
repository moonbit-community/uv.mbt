///|
let buffer : Bytes = Bytes::make(1024, 0)

///|
fn on_write(uv : @uv.Loop, file : @uv.File) -> Unit {
  uv.fs_read(file, [buffer], on_read(uv, file, _), fn(errno) {
    println("error reading file: \{errno}")
  }) catch {
    error => println("error reading file: \{error}")
  }
}

///|
fn on_read(uv : @uv.Loop, file : @uv.File, count : Int) -> Unit {
  if count == 0 {
    uv.fs_close(file, () => (), fn(errno) {
      println("error closing file: \{errno}")
    }) catch {
      error => println("error closing file: \{error}")
    }
  } else {
    uv.fs_write(@uv.stdout(), [buffer[:count]], _ => on_write(uv, file), fn(
      errno
    ) {
      println("error writing file: \{errno}")
    }) catch {
      error => println("error writing file: \{error}")
    }
  }
}

///|
fn on_open(uv : @uv.Loop, file : @uv.File) -> Unit {
  uv.fs_read(file, [buffer], fn(count) { on_read(uv, file, count) }, fn(errno) {
    println("error reading file: \{errno}")
  }) catch {
    error => println("error reading file: \{error}")
  }
}

///|
fn main {
  try {
    let uv = @uv.Loop::new()
    let args = @uv.args()
    uv.fs_open(
      args[1],
      @uv.OpenFlags::read_only(),
      0,
      file => on_open(uv, file),
      errno => println("error opening file: \{errno}"),
    )
    uv.run(Default)
    uv.close()
  } catch {
    error => println("error: \{error}")
  }
}
