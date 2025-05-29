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
/// Shares an object safely between threads.
///
/// In MoonBit, the default reference counting (RC) for objects is not atomic,
/// so it is not safe to share most objects directly between threads.
///
/// To enable safe sharing, we use a separate atomic reference counter (ARC)
/// stored alongside the actual object data. The MoonBit object itself is
/// managed by non-atomic RC, but the shared payload is managed by ARC.
///
/// When you want to share an object:
/// - The MoonBit object holds a pointer to a heap-allocated block containing
///   both the ARC and the payload (e.g., a mutex or thread handle).
/// - Copying the MoonBit object only copies the pointer; the ARC is incremented
///   atomically (guarded by a mutex if needed).
/// - When a copy is dropped, the ARC is decremented atomically. When ARC
///   reaches zero, the payload is freed.
///
/// Example: `uv_thread_t` stores an `arc` field and a `uv_mutex_t` object in a
/// heap-allocated block. All increments/decrements of `arc` are protected by
/// the mutex to ensure thread safety.
///
/// Diagram:
///                (thread 0)                 (thread 1)
///                +--------+                 +--------+
///                | rc (M) |                 | rc (M) |
///                +--------+                 +--------+
///                      \                       /
///                       \---> +---------+ <---/
///                             | arc (F) |
///                             +---------+
///                             | mutex   |
///                             +---------+
///                             | payload |
///                             +----+----+
///
/// The `Share` trait provides a `share` method to allow implementor of this
/// trait to create a new MoonBit object pointing to the same shared payload,
/// incrementing the ARC safely.
pub trait Share {
  share(Self) -> Self
}

///|
pub impl Share for Mutex with share(self : Mutex) -> Mutex {
  let other = uv_mutex_make()
  uv_mutex_copy(self, other)
  return other
}
