///|
pub extern "c" fn disable_stdio_inheritance() = "moonbit_uv_disable_stdio_inheritance"

///|
type Process

///|
pub impl ToHandle for Process with to_handle(self) = "%identity"

///|
pub impl ToHandle for Process with of_handle(handle) = "%identity"

///|
extern "c" fn uv_process_get_pid(process : Process) -> Int = "moonbit_uv_process_get_pid"

///|
pub fn Process::pid(self : Process) -> Int {
  return uv_process_get_pid(self)
}

///|
extern "c" fn uv_process_make() -> Process = "moonbit_uv_process_make"

///|
type ProcessOptions

///|
priv enum ProcessFlag {
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
fn ProcessFlag::to_int(self : ProcessFlag) -> UInt = "%identity"

///|
extern "c" fn uv_process_options_make() -> ProcessOptions = "moonbit_uv_process_options_make"

///|
extern "c" fn uv_process_options_set_exit_cb(
  process_options : ProcessOptions,
  exit_cb : (Process, Int64, Int) -> Unit
) = "moonbit_uv_process_options_set_exit_cb"

///|
extern "c" fn uv_process_options_set_file(
  process_options : ProcessOptions,
  file : Bytes
) = "moonbit_uv_process_options_set_file"

///|
extern "c" fn uv_process_options_set_args(
  process_options : ProcessOptions,
  args : FixedArray[Bytes?]
) = "moonbit_uv_process_options_set_args"

///|
extern "c" fn uv_process_options_set_env(
  process_options : ProcessOptions,
  env : FixedArray[Bytes?]
) = "moonbit_uv_process_options_set_env"

///|
extern "c" fn uv_process_options_set_cwd(
  process_options : ProcessOptions,
  cwd : Bytes
) = "moonbit_uv_process_options_set_cwd"

///|
extern "c" fn uv_process_options_set_flags(
  process_options : ProcessOptions,
  flags : UInt
) = "moonbit_uv_process_options_set_flags"

///|
extern "c" fn uv_process_options_set_stdio(
  process_options : ProcessOptions,
  stdio : FixedArray[StdioContainer]
) = "moonbit_uv_process_options_set_stdio"

///|
extern "c" fn uv_process_options_set_uid(
  process_options : ProcessOptions,
  uid : Uid
) = "moonbit_uv_process_options_set_uid"

///|
extern "c" fn uv_process_options_set_gid(
  process_options : ProcessOptions,
  gid : Gid
) = "moonbit_uv_process_options_set_gid"

///|
pub fn[Ntbs : ToNtbs] ProcessOptions::new(
  file : Ntbs,
  args : Array[@string.View],
  env? : Array[@string.View],
  cwd? : @string.View,
  stdio? : Array[StdioContainer],
  uid? : Uid,
  gid? : Gid,
  exit_cb : (Process, Int64, Int) -> Unit
) -> ProcessOptions {
  let mut flags = 0U
  let options = uv_process_options_make()
  uv_process_options_set_exit_cb(options, exit_cb)
  let file = file.to_ntbs()
  uv_process_options_set_file(options, file)
  let args = FixedArray::makei(args.length() + 1, fn(i) {
    if i == args.length() {
      return None
    } else {
      return Some(ToNtbs::to_ntbs(args[i]))
    }
  })
  uv_process_options_set_args(options, args)
  if env is Some(env) {
    let env = FixedArray::makei(env.length() + 1, fn(i) {
      if i == env.length() {
        return None
      } else {
        return Some(ToNtbs::to_ntbs(env[i]))
      }
    })
    uv_process_options_set_env(options, env)
  }
  if cwd is Some(cwd) {
    let cwd = ToNtbs::to_ntbs(cwd)
    uv_process_options_set_cwd(options, cwd)
  }
  if stdio is Some(stdio) {
    let stdio = FixedArray::makei(stdio.length(), fn(i) { return stdio[i] })
    uv_process_options_set_stdio(options, stdio)
  }
  if uid is Some(uid) {
    flags = flags | SetUID.to_int()
    uv_process_options_set_uid(options, uid)
  }
  if gid is Some(gid) {
    flags = flags | SetGID.to_int()
    uv_process_options_set_gid(options, gid)
  }
  uv_process_options_set_flags(options, flags)
  return options
}

///|
type StdioContainer Bytes

///|
pub extern "c" fn StdioContainer::ignore() -> StdioContainer = "moonbit_uv_stdio_container_ignore"

///|
extern "c" fn uv_stdio_container_create_pipe(
  stream : Stream,
  readable~ : Bool = false,
  writable~ : Bool = false,
  non_block~ : Bool = false
) -> StdioContainer = "moonbit_uv_stdio_container_create_pipe"

///|
pub fn[Stream : ToStream] StdioContainer::create_pipe(
  stream : Stream,
  readable~ : Bool = false,
  writable~ : Bool = false,
  non_block~ : Bool = false
) -> StdioContainer {
  return uv_stdio_container_create_pipe(
    stream.to_stream(),
    readable~,
    writable~,
    non_block~,
  )
}

///|
extern "c" fn uv_stdio_container_inherit_fd(fd : Int) -> StdioContainer = "moonbit_uv_stdio_container_inherit_fd"

///|
pub fn StdioContainer::inherit_file(file : File) -> StdioContainer {
  return uv_stdio_container_inherit_fd(file._)
}

///|
pub extern "c" fn StdioContainer::inherit_stream(
  stream : Stream
) -> StdioContainer = "moonbit_uv_stdio_container_inherit_stream"

///|
type Uid Int

///|
type Gid Int

///|
extern "c" fn uv_spawn(
  uv : Loop,
  process : Process,
  options : ProcessOptions
) -> Int = "moonbit_uv_spawn"

///|
pub fn spawn(self : Loop, options : ProcessOptions) -> Process!Errno {
  let process = uv_process_make()
  let status = uv_spawn(self, process, options)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return process
}

///|
extern "c" fn uv_process_kill(process : Process, signum : Int) -> Int = "moonbit_uv_process_kill"

///|
pub fn Process::kill(self : Process, signum : Signum) -> Unit!Errno {
  let status = uv_process_kill(self, signum._)
  if status < 0 {
    raise Errno::of_int(status)
  }
}
