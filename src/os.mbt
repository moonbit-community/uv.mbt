///|
extern "c" fn uv_os_uname(buffer : Bytes) -> Int = "moonbit_uv_os_uname"

///|
struct Utsname {
  sysname : String
  release : String
  version : String
  machine : String
}

///|
pub fn Utsname::sysname(self : Utsname) -> String {
  self.sysname
}

///|
pub fn Utsname::release(self : Utsname) -> String {
  self.release
}

///|
pub fn Utsname::version(self : Utsname) -> String {
  self.version
}

///|
pub fn Utsname::machine(self : Utsname) -> String {
  self.machine
}

///|
pub fn os_uname() -> Utsname!Errno {
  fn decode(bytes : @bytes.View) -> String {
    let buffer = @buffer.new()
    for i in 0..<bytes.length() {
      let byte = bytes[i]
      if byte == 0 {
        break
      }
      buffer.write_byte(byte)
    }
    let decoder = @encoding.decoder(UTF8)
    return decoder.decode_lossy(buffer.contents())
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
