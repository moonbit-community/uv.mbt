///|
type FsEvent

///|
pub impl ToHandle for FsEvent with to_handle(self) = "%identity"

///|
pub impl ToHandle for FsEvent with of_handle(handle : Handle) -> FsEvent = "%identity"

///|
extern "c" fn uv_fs_event_make() -> FsEvent = "moonbit_uv_fs_event_make"

///|
extern "c" fn uv_fs_event_init(uv : Loop, fs_event : FsEvent) -> Int = "moonbit_uv_fs_event_init"

///|
pub fn FsEvent::new(self : Loop) -> FsEvent!Errno {
  let fs_event = uv_fs_event_make()
  let status = uv_fs_event_init(self, fs_event)
  if status < 0 {
    raise Errno::of_int(status)
  }
  return fs_event
}

///|
pub enum FsEventType {
  Rename = 1
  Change = 2
} derive(Show)

///|
pub impl ToJson for FsEventType with to_json(self) {
  match self {
    Rename => "Rename"
    Change => "Change"
  }
}

///|
const UV_RENAME = 1

///|
const UV_CHANGE = 2

///|
extern "c" fn uv_fs_event_start(
  fs_event : FsEvent,
  cb : (FsEvent, @c.Pointer[Byte], Int, Int) -> Unit,
  path : Bytes,
  flags : Int
) -> Int = "moonbit_uv_fs_event_start"

///|
type FsEventFlags Int

///|
const UV_FS_EVENT_RECURSIVE = 4

///|
pub fn FsEventFlags::new(recursive~ : Bool = false) -> FsEventFlags {
  let mut flags = 0
  if recursive {
    flags = flags | UV_FS_EVENT_RECURSIVE
  }
  return flags
}

///|
pub fn FsEvent::start(
  self : FsEvent,
  path : String,
  flags : FsEventFlags,
  event_cb : (FsEvent, String?, Array[FsEventType]) -> Unit,
  error_cb : (FsEvent, String?, Errno) -> Unit
) -> Unit!Errno {
  fn uv_cb(
    fs_event : FsEvent,
    filename : @c.Pointer[Byte],
    events : Int,
    status : Int
  ) {
    let filename = if filename.is_null() {
      None
    } else {
      let buffer = @buffer.new()
      for i = 0; filename[i] != 0; i = i + 1 {
        buffer.write_byte(filename[i])
      }
      Some(@encoding.decode_lossy(buffer.contents(), encoding=UTF8))
    }
    if status < 0 {
      error_cb(fs_event, filename, Errno::of_int(status))
    } else {
      let event_types = []
      if (events & UV_RENAME) != 0 {
        event_types.push(Rename)
      }
      if (events & UV_CHANGE) != 0 {
        event_types.push(Change)
      }
      event_cb(fs_event, filename, event_types)
    }
  }

  let path = path.to_ntbs()
  let status = uv_fs_event_start(self, uv_cb, path, flags._)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_event_stop(fs_event : FsEvent) -> Int = "moonbit_uv_fs_event_stop"

///|
pub fn FsEvent::stop(self : FsEvent) -> Unit!Errno {
  let status = uv_fs_event_stop(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_fs_event_getpath(
  fs_event : FsEvent,
  buffer : Bytes,
  length : FixedArray[Int]
) -> Int = "moonbit_uv_fs_event_getpath"

///|
pub fn FsEvent::get_path(self : FsEvent) -> String!Errno {
  let buffer = Bytes::make(64, 0)
  let length : FixedArray[Int] = [buffer.length()]
  let mut status = uv_fs_event_getpath(self, buffer, length)
  if status == uv_ENOBUFS() {
    let buffer = Bytes::make(length[0], 0)
    status = uv_fs_event_getpath(self, buffer, length)
  }
  if status < 0 {
    raise Errno::of_int(status)
  }
  @encoding.decode_lossy(buffer, encoding=UTF8)
}
