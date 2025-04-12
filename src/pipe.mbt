///|
type Pipe

///|
pub fn Pipe::to_handle(self : Pipe) -> Handle = "%identity"

///|
pub fn Pipe::to_stream(self : Pipe) -> Stream = "%identity"

///|
pub impl ToHandle for Pipe with to_handle(self) {
  self.to_handle()
}

///|
pub impl ToHandle for Pipe with of_handle(self) = "%identity"

///|
pub impl ToStream for Pipe with to_stream(self) {
  self.to_stream()
}

///|
pub impl ToStream for Pipe with of_stream(self) = "%identity"

///|
extern "c" fn uv_pipe_make() -> Pipe = "moonbit_uv_pipe_make"

///|
extern "c" fn uv_pipe_init(self : Loop, pipe : Pipe, ipc : Bool) -> Int = "moonbit_uv_pipe_init"

///|
extern "c" fn uv_pipe_bind(self : Pipe, name : Bytes, flags : Int) -> Int = "moonbit_uv_pipe_bind"

///|
extern "c" fn uv_pipe(
  fds : FixedArray[Int],
  read_flags : Int,
  write_flags : Int
) -> Int = "moonbit_uv_pipe"

///|
pub fn Pipe::new(self : Loop, ipc~ : Bool = false) -> Pipe!Errno {
  let pipe = uv_pipe_make()
  let status = uv_pipe_init(self, pipe, ipc)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return pipe
}

///|
pub fn Pipe::bind(self : Pipe, name : String, flags : Int) -> Unit!Errno {
  let name = to_c_string(name)
  let status = uv_pipe_bind(self, name, flags)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn pipe(read_flags : Int, write_flags : Int) -> (File, File)!Errno {
  let fds : FixedArray[Int] = [0, 0]
  let status = uv_pipe(fds, read_flags, write_flags)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return (File(fds[0]), File(fds[1]))
}
