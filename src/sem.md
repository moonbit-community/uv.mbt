# UV Semaphore Implementation

This document describes the implementation of semaphore support (`uv_sem`) for the MoonBit UV library, following the same patterns used for the existing mutex implementation.

## Overview

A semaphore is a synchronization primitive that maintains a count and allows threads to wait when the count is zero and signal to increment the count. This implementation provides a thread-safe semaphore using libuv's `uv_sem_*` functions.

## Implementation Details

### MoonBit API (src/sem.mbt)

The semaphore is implemented as an opaque type `Sem` with the following public interface:

```moonbit
type Sem

// Constructor
pub fn Sem::new(value : UInt) -> Sem raise Errno

// Operations
pub fn Sem::post(self : Sem) -> Unit
pub fn Sem::wait(self : Sem) -> Unit
pub fn Sem::trywait(self : Sem) -> Unit raise Errno

// Sharing across threads
pub impl Share for Sem
```

#### Key Methods

- **`Sem::new(value)`**: Creates a new semaphore with the specified initial count
- **`post()`**: Increments the semaphore count, potentially unblocking waiting threads
- **`wait()`**: Decrements the semaphore count, blocking if count is zero
- **`trywait()`**: Attempts to decrement the count without blocking, raises `Errno` if would block
- **`share()`**: Creates a new reference to the same semaphore for sharing between threads

### C Implementation (src/uv.c)

The C implementation follows the same atomic reference counting pattern as the mutex implementation:

```c
typedef struct moonbit_uv_sem_s {
#if __STDC_VERSION__ >= 201112L
  struct {
    _Atomic int32_t arc;  // Atomic reference counter
    uv_sem_t object;      // The actual semaphore
  } *block;
#else
  struct {
    int32_t arc;          // Reference counter
    uv_mutex_t mutex;     // Mutex for thread-safe ref counting
    uv_sem_t object;      // The actual semaphore
  } *block;
#endif
} moonbit_uv_sem_t;
```

#### Key Features

- **Thread-safe reference counting**: Uses atomic operations when available (C11+), otherwise protected by mutex
- **Memory management**: Automatic cleanup when reference count reaches zero
- **libuv integration**: Direct mapping to `uv_sem_init`, `uv_sem_post`, `uv_sem_wait`, `uv_sem_trywait`, `uv_sem_destroy`

### Interface Declaration (src/uv.mbti)

The semaphore type is exposed in the module interface:

```moonbit
type Sem
fn Sem::new(UInt) -> Self raise Errno
fn Sem::post(Self) -> Unit
fn Sem::trywait(Self) -> Unit raise Errno
fn Sem::wait(Self) -> Unit
impl Share for Sem
```

### Tests (src/sem_test.mbt)

Comprehensive test suite covering:

1. **Basic operations**: new, post, wait, trywait
2. **Initial value 0**: Testing blocking behavior
3. **Initial value > 1**: Testing multiple decrements
4. **Sharing functionality**: Verifying shared semaphores work correctly
5. **Error conditions**: Testing trywait failures

## Usage Examples

### Basic Usage

```moonbit
// Create semaphore with count of 1 (similar to a binary semaphore)
let sem = Sem::new(1U)

// Wait (decrements to 0)
sem.wait()

// Try to wait again (should fail)
try {
  sem.trywait()
  // This won't execute
} catch {
  _errno => println("Expected: semaphore not available")
}

// Signal (increments to 1)
sem.post()

// Now wait should succeed
sem.wait()
```

### Resource Pool Example

```moonbit
// Create semaphore representing 3 available resources
let resource_pool = Sem::new(3U)

// Acquire a resource
resource_pool.wait()
// ... use resource ...

// Release resource back to pool
resource_pool.post()
```

### Thread Sharing

```moonbit
fn worker_thread(sem : Sem) -> Unit {
  // Wait for signal from main thread
  sem.wait()
  println("Worker thread activated!")
}

fn main {
  let sem = Sem::new(0U)  // Start with no permits

  // Share semaphore with worker thread
  let shared_sem = sem.share()
  // ... start worker thread with shared_sem ...

  // Signal worker thread
  sem.post()
}
```

## Comparison with Mutex

| Feature | Mutex | Semaphore |
|---------|-------|-----------|
| **Purpose** | Mutual exclusion | Resource counting |
| **Count** | Binary (locked/unlocked) | Integer (0 to N) |
| **Operations** | lock/unlock/trylock | wait/post/trywait |
| **Blocking** | lock() blocks if locked | wait() blocks if count == 0 |
| **Non-blocking** | trylock() never blocks | trywait() never blocks |

## Implementation Notes

1. **Memory Safety**: The implementation uses the same proven ARC pattern as mutex for safe sharing across threads

2. **Error Handling**: Follows MoonBit conventions with `raise Errno` for operations that can fail

3. **libuv Compatibility**: Direct mapping to libuv's semaphore API ensures platform compatibility

4. **Performance**: Minimal overhead - direct calls to libuv functions with atomic reference counting

## Files Modified/Added

- **Added**: `src/sem.mbt` - Main semaphore implementation
- **Added**: `src/sem_test.mbt` - Test suite
- **Modified**: `src/uv.c` - Added C implementation functions
- **Modified**: `src/uv.mbti` - Added type and function declarations
- **Modified**: `src/moon.pkg.json` - Added new files to build configuration

## Testing

All tests pass successfully:

- 4 semaphore-specific tests added
- Integration with existing test suite
- Tests cover both success and error paths
- Verifies thread-sharing functionality

The implementation is ready for production use and follows the established patterns of the UV library.
