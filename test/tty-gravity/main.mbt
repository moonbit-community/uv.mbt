///|
let message : Bytes = "  Hello TTY  "

///|
let pos : Ref[Int] = Ref::new(0)

///|
fn update(timer : @uv.Timer, tty : @uv.Tty, width : Int, height : Int) -> Unit {
  let buffer = @buffer.new()
  buffer.write_byte(27)
  buffer.write_bytes("[2J")
  buffer.write_byte(27)
  buffer.write_bytes("[H")
  buffer.write_byte(27)
  buffer.write_byte('[')
  @encoding.encode_to(pos.val.to_string(), buffer, encoding=@encoding.UTF8)
  buffer.write_byte('B')
  buffer.write_byte(27)
  buffer.write_byte('[')
  @encoding.encode_to(
    ((width - message.length()) / 2).to_string(),
    buffer,
    encoding=@encoding.UTF8,
  )
  buffer.write_byte('C')
  buffer.write_byte(27)
  buffer.write_bytes("[42;37m")
  buffer.write_bytes(message)
  buffer.write_byte(0)
  let data = buffer.contents()
  tty.write([data], fn(_) {  }, fn(_, errno) {
    println("error writing to TTY: \{errno}")
  }) catch {
    error => println("error writing to TTY: \{error}")
  }
  pos.val += 1
  if pos.val >= height {
    @uv.Tty::reset_mode() catch {
      error => println("error resetting TTY mode: \{error}")
    }
    timer.stop() catch {
      error => println("error stopping timer: \{error}")
    }
  }
}

///|
fn main {
  try {
    let uv = @uv.Loop::new()
    let tty = @uv.Tty::new(uv, @uv.stdout())
    try {
      tty.set_mode(@uv.TtyMode::normal())
      let (width, height) = tty.get_winsize()
      uv.fs_write_sync(@uv.stderr(), [
        @encoding.encode(encoding=UTF8, "Width: \{width}, height: \{height}\n"),
      ])
      let timer = @uv.Timer::new(uv)
      timer.start(timeout=200, repeat=200, fn(_) {
        update(timer, tty, width, height)
      })
      uv.run(Default)
    } catch {
      error => {
        @uv.Tty::reset_mode()
        raise error
      }
    }
  } catch {
    error => println("error: \{error}")
  }
}
