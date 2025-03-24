///|
pub extern "c" fn strerror_r(err : Int, bytes : Bytes) -> Unit = "moonbit_uv_strerror_r"

///|
pub fn strerror(errno : Int) -> String {
  let message = Bytes::make(256, 0)
  strerror_r(errno, message)
  let message = @encoding.decoder(UTF8).decode_lossy(message)
  return message
}

///|
pub type! Errno Int

///|
pub fn errno(status : Int) -> Unit!Errno {
  if status < 0 {
    raise Errno(status)
  }
}

///|
let errno_map : Map[Int, String] = Map::new()

///|
pub impl Show for Errno with output(self : Errno, logger : &Logger) -> Unit {
  let Errno(errno) = self
  if errno_map.get(errno) is Some(message) {
    logger.write_string(message)
    return
  }
  let message = Bytes::make(256, 0)
  strerror_r(errno, message)
  let message = @encoding.decoder(UTF8).decode_lossy(message)
  errno_map[errno] = message
  logger.write_string(message)
}

///|
pub const EOF = -4095
