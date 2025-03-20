///|
pub extern "c" fn uv_disable_stdio_inheritance() = "moonbit_uv_disable_stdio_inheritance"

///|
priv type UvProcess Bytes

///|
extern "c" fn uv_process_t() -> UvProcess = "moonbit_uv_process_t"

///|
priv type UvProcessOptions Bytes

///|
extern "c" fn uv_process_options_t() -> UvProcessOptions = "moonbit_uv_process_options_t"

///|
extern "c" fn uv_process_options_set_file(
  options : UvProcessOptions,
  file : Bytes
) = "moonbit_uv_process_options_set_file"

///|
extern "c" fn uv_process_options_set_args(
  options : UvProcessOptions,
  args : FixedArray[Bytes]
) = "moonbit_uv_process_options_set_args"

///|
extern "c" fn uv_process_options_set_env(
  options : UvProcessOptions,
  env : FixedArray[Bytes]
) = "moonbit_uv_process_options_set_env"

///|
extern "c" fn uv_process_options_set_cwd(
  options : UvProcessOptions,
  cwd : Bytes
) = "moonbit_uv_process_options_set_cwd"

///|
extern "c" fn uv_process_options_set_flags(
  options : UvProcessOptions,
  flags : ProcessFlags
) = "moonbit_uv_process_options_set_flags"

///|
enum StdioFlags {
  Ignore = 0x00
  CreatePipe = 0x01
  InheritFd = 0x02
  InheritStream = 0x04
  ReadablePipe = 0x10
  WritablePipe = 0x20
  NonBlockPipe = 0x40
}

///|
pub impl BitOr for StdioFlags with lor(self : StdioFlags, other : StdioFlags) -> StdioFlags = "%i32_lor"

///|
priv type UvStdioContainer Bytes

///|
extern "c" fn uv_stdio_container_stream(
  flags : StdioFlags,
  stream : Stream
) -> UvStdioContainer = "moonbit_uv_stdio_container_stream"

///|
extern "c" fn uv_stdio_container_fd(
  flags : StdioFlags,
  fd : Int
) -> UvStdioContainer = "moonbit_uv_stdio_container_fd"

///|
extern "c" fn uv_process_options_set_stdio(
  options : UvProcessOptions,
  stdio : FixedArray[UvStdioContainer]
) = "moonbit_uv_process_options_set_stdio"

///|
enum ProcessFlags {
  SetUID = 1
  SetGID = 2
  WindowsVerbatimArguments = 4
  Detached = 8
  WindowsHide = 16
  WindowsHideConsole = 32
  WindowsHideGui = 64
  WindowsFilePathExactName = 128
}

///|
pub impl BitOr for ProcessFlags with lor(
  self : ProcessFlags,
  other : ProcessFlags
) -> ProcessFlags = "%i32_lor"

///|
extern "c" fn uv_spawn(
  self : Loop,
  process : UvProcess,
  options : UvProcessOptions
) -> Int = "moonbit_uv_spawn"

///|
type Process UvProcess

///|
pub fn spawn(
  self : Loop,
  file : String,
  args : Array[String],
  env? : Map[String, String],
  cwd? : String,
  flags? : ProcessFlags
) -> Process!Errno {
  let process = uv_process_t()
  let options = uv_process_options_t()
  uv_process_options_set_file(options, @encoding.encode(UTF8, file))
  let args = FixedArray::makei(args.length(), fn(i) {
    @encoding.encode(UTF8, args[i])
  })
  uv_process_options_set_args(options, args)
  if env is Some(env) {
    let uv_env = []
    for key, value in env {
      let env = key + "=" + value
      uv_env.push(@encoding.encode(UTF8, env))
    }
    uv_process_options_set_env(options, FixedArray::from_array(uv_env))
  }
  if cwd is Some(cwd) {
    uv_process_options_set_cwd(options, @encoding.encode(UTF8, cwd))
  }
  if flags is Some(flags) {
    uv_process_options_set_flags(options, flags)
  }
  uv_spawn(self, process, options) |> errno!()
  return process
}
