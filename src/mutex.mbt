///|
type Mutex

///|
extern "c" fn uv_mutex_make() -> Mutex = "moonbit_uv_mutex_make"

///|
extern "c" fn uv_mutex_init(mutex : Mutex) -> Int = "moonbit_uv_mutex_init"

///|
pub fn Mutex::new() -> Mutex!Errno {
  let mutex = uv_mutex_make()
  let status = uv_mutex_init(mutex)
  if status != 0 {
    raise Errno::of_int(status)
  }
  return mutex
}

///|
extern "c" fn uv_mutex_copy(mutex : Mutex, other : Mutex) = "moonbit_uv_mutex_copy"

///|
extern "c" fn uv_mutex_lock(mutex : Mutex) = "moonbit_uv_mutex_lock"

///|
extern "c" fn uv_mutex_trylock(mutex : Mutex) -> Int = "moonbit_uv_mutex_trylock"

///|
extern "c" fn uv_mutex_unlock(mutex : Mutex) = "moonbit_uv_mutex_unlock"

///|
pub fn Mutex::lock(self : Mutex) -> Unit {
  uv_mutex_lock(self)
}

///|
pub fn Mutex::trylock(self : Mutex) -> Unit!Errno {
  let status = uv_mutex_trylock(self)
  if status < 0 {
    raise Errno::of_int(status)
  }
}

///|
pub fn Mutex::unlock(self : Mutex) -> Unit {
  uv_mutex_unlock(self)
}

///|
pub trait Share {
  share(Self) -> Self
}

///|
pub impl Share for Mutex with share(self : Mutex) -> Mutex {
  let other = uv_mutex_make()
  uv_mutex_copy(self, other)
  return other
}
