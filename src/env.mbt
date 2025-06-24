///|
extern "c" fn uv_os_getenv(
  name : Bytes,
  bytes : Bytes,
  size : FixedArray[Int]
) -> Int = "moonbit_uv_os_getenv"

///|
pub fn[ToNtbs : ToNtbs] os_getenv(name : ToNtbs) -> String? raise Errno {
  let name = name.to_ntbs()
  let mut buffer = Bytes::make(256, 0)
  let length : FixedArray[Int] = [buffer.length()]
  let mut status = uv_os_getenv(name, buffer, length)
  if status == _ENOENT {
    return None
  }
  if status == _ENOBUFS {
    buffer = Bytes::make(length[0], 0)
    status = uv_os_getenv(name, buffer, length)
  }
  if status < 0 {
    raise Errno::of_int(status)
  }
  Some(@encoding.decode_lossy(encoding=UTF8, buffer[:length[0]]))
}

///|
extern "c" fn uv_os_setenv(name : Bytes, value : Bytes) -> Int = "moonbit_uv_os_setenv"

///|
pub fn[Name : ToNtbs, Value : ToNtbs] os_setenv(
  name : Name,
  value : Value
) -> Unit raise Errno {
  let status = uv_os_setenv(name.to_ntbs(), value.to_ntbs())
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
extern "c" fn uv_os_unsetenv(name : Bytes) -> Int = "moonbit_uv_os_unsetenv"

///|
pub fn[Name : ToNtbs] os_unsetenv(name : Name) -> Unit raise Errno {
  let status = uv_os_unsetenv(name.to_ntbs())
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
type Environ

///|
extern "c" fn uv_environ_make() -> Environ = "moonbit_uv_environ_make"

///|
extern "c" fn uv_os_environ(environ : Environ) -> Int = "moonbit_uv_os_environ"

///|
pub fn os_environ() -> Environ raise Errno {
  let environ = uv_environ_make()
  let status = uv_os_environ(environ)
  if status < 0 {
    raise Errno::of_int(status)
  }
  environ
}

///|
#borrow(environ)
extern "c" fn uv_environ_count(environ : Environ) -> Int = "moonbit_uv_environ_count"

///|
#borrow(environ)
extern "c" fn uv_environ_get_name(
  environ : Environ,
  index : Int
) -> @c.Pointer[Byte] = "moonbit_uv_environ_get_name"

///|
#borrow(environ)
extern "c" fn uv_environ_get_value(
  environ : Environ,
  index : Int
) -> @c.Pointer[Byte] = "moonbit_uv_environ_get_value"

///|
pub fn Environ::iter2(self : Environ) -> Iter2[String, String] {
  fn read_c_string(ptr : @c.Pointer[Byte]) -> String {
    let buf = @buffer.new()
    for i = 0; ptr[i] != 0; i = i + 1 {
      buf.write_byte(ptr[i])
    }
    let bytes = buf.contents()
    @encoding.decode_lossy(encoding=UTF8, bytes)
  }

  let count = uv_environ_count(self)
  Iter2::new(fn(yield_) {
    for i in 0..<count {
      let name = read_c_string(uv_environ_get_name(self, i))
      let value = read_c_string(uv_environ_get_value(self, i))
      match yield_(name, value) {
        IterEnd => break IterEnd
        IterContinue => ()
      }
    } else {
      IterContinue
    }
  })
}
