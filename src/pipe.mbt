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
#borrow(uv, pipe)
extern "c" fn uv_pipe_init(uv : Loop, pipe : Pipe, ipc : Bool) -> Int = "moonbit_uv_pipe_init"

///|
extern "c" fn uv_pipe_bind(pipe : Pipe, name : Bytes, flags : UInt) -> Int = "moonbit_uv_pipe_bind"

///|
extern "c" fn uv_pipe(
  fds : FixedArray[Int],
  read_flags : Int,
  write_flags : Int
) -> Int = "moonbit_uv_pipe"

///|
pub fn Pipe::new(self : Loop, ipc~ : Bool = false) -> Pipe raise Errno {
  let pipe = uv_pipe_make()
  let status = uv_pipe_init(self, pipe, ipc)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return pipe
}

///|
type PipeBindFlags UInt

///|
const PIPE_NO_TRUNCATE : UInt = 1U << 0

///|
pub fn PipeBindFlags::new(truncate~ : Bool = true) -> PipeBindFlags {
  let mut flags = 0U
  if not(truncate) {
    flags = flags | PIPE_NO_TRUNCATE
  }
  return flags
}

///|
pub fn[Ntbs : ToNtbs] Pipe::bind(
  self : Pipe,
  name : Ntbs,
  flags : PipeBindFlags
) -> Unit raise Errno {
  let name = name.to_ntbs()
  let status = uv_pipe_bind(self, name, flags._)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn pipe(read_flags : Int, write_flags : Int) -> (File, File) raise Errno {
  let fds : FixedArray[Int] = [0, 0]
  let status = uv_pipe(fds, read_flags, write_flags)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return (File(fds[0]), File(fds[1]))
}
