///|
extern "c" fn uv_os_uname(buffer : Bytes) -> Int = "moonbit_uv_os_uname"

///|
struct Utsname {
  sysname : @string.View
  release : @string.View
  version : @string.View
  machine : @string.View
}

///|
pub fn Utsname::sysname(self : Utsname) -> @string.View {
  self.sysname
}

///|
pub fn Utsname::release(self : Utsname) -> @string.View {
  self.release
}

///|
pub fn Utsname::version(self : Utsname) -> @string.View {
  self.version
}

///|
pub fn Utsname::machine(self : Utsname) -> @string.View {
  self.machine
}

///|
pub fn os_uname() -> Utsname!Errno {
  fn decode(bytes : @bytes.View) -> @string.View {
    let buffer = @buffer.new()
    for i in 0..<bytes.length() {
      let byte = bytes[i]
      if byte == 0 {
        break
      }
      buffer.write_byte(byte)
    }
    return @encoding.decode_lossy(encoding=UTF8, buffer.contents())
  }

  let buffer = Bytes::make(256 * 4, 0)
  let status = uv_os_uname(buffer)
  if status < 0 {
    raise Errno::of_int(status)
  }
  let sysname = decode([..buffer[0:256]])
  let release = decode([..buffer[256:512]])
  let version = decode([..buffer[512:768]])
  let machine = decode([..buffer[768:1024]])
  { sysname, release, version, machine }
}
