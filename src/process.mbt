///|
pub extern "c" fn uv_disable_stdio_inheritance() = "moonbit_uv_disable_stdio_inheritance"

///|
type Process

///|
pub extern "c" fn process_close(
  self : Process,
  cb : (Process) -> Unit
) -> Unit = "moonbit_uv_process_close"

///|
pub extern "c" fn process_get_pid(process : Process) -> Int = "moonbit_uv_process_get_pid"

///|
pub extern "c" fn process_alloc() -> Process = "moonbit_uv_process_alloc"

///|
type ProcessOptions Bytes

///|
pub extern "c" fn process_options_alloc() -> ProcessOptions = "moonbit_uv_process_options_alloc"

///|
pub extern "c" fn process_options_set_file(
  options : ProcessOptions,
  file : Bytes
) = "moonbit_uv_process_options_set_file"

///|
pub extern "c" fn process_options_set_args(
  options : ProcessOptions,
  args : FixedArray[Bytes?]
) = "moonbit_uv_process_options_set_args"

///|
pub extern "c" fn process_options_set_env(
  options : ProcessOptions,
  env : FixedArray[Bytes?]
) = "moonbit_uv_process_options_set_env"

///|
pub extern "c" fn process_options_set_cwd(
  options : ProcessOptions,
  cwd : Bytes
) = "moonbit_uv_process_options_set_cwd"

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
pub extern "c" fn process_options_set_flags(
  options : ProcessOptions,
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
type StdioContainer Bytes

///|
pub extern "c" fn stdio_container_alloc() -> StdioContainer = "moonbit_uv_stdio_container_t"

///|
pub extern "c" fn stdio_container_set_flags(
  container : StdioContainer,
  flags : StdioFlags
) = "moonbit_uv_stdio_container_set_flags"

///|
pub extern "c" fn uv_stdio_container_stream(
  flags : StdioFlags,
  stream : Stream
) -> StdioContainer = "moonbit_uv_stdio_container_stream"

///|
pub extern "c" fn uv_stdio_container_fd(
  flags : StdioFlags,
  fd : Int
) -> StdioContainer = "moonbit_uv_stdio_container_fd"

///|
pub extern "c" fn process_options_set_stdio(
  options : ProcessOptions,
  stdio : FixedArray[StdioContainer]
) = "moonbit_uv_process_options_set_stdio"

///|
pub extern "c" fn spawn(
  self : Loop,
  handle : Process,
  options : ProcessOptions,
  exit_cb : (Process, Int64, Int) -> Unit
) -> Int = "moonbit_uv_spawn"
