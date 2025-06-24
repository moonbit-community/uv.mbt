# Memory Management of `uv.mbt`

The memory management system of `uv.mbt` is designed with the following goals:

1. **No segmentation-fault**. No form of public API usage should lead to a
   segmentation-fault.
2. **Minimal memory-leak for correct API use**. If all resource is correctly
   released by calling calls like `close`/`fs_req_cleanup`, there should be no
   memory leaks, unless there is a bug/intrinsic limitation.

Base on the two goals above, we can have the following corollaries:

1. **No manual memory management** in public API. Manual memory management could
   lead to problems like double-free, use-after-free, and memory-leak.
2. **All libuv object should be managed by MoonBit**. By using the external
   object in MoonBit, we can free memory when it is not referenced in the code.
3. **No automatic resource cleanup**. Even though some resource cleanup is
   actually freeing some memory (e.g. `uv_fs_req_cleanup`), it is rather
   counter-intuitive and error-prone to use `ignore(...)` to prevent a object
   from being garbage-collected.

To achieve the these goals and corollaries within a controlled complexity, we
build a simplified model of the ownership of objects in libuv:

1. **Initialization**. When a resource is initialized, a shared reference will
   be stored into the event-loop, and the resource will holds a shared reference
   to all its callbacks.
2. **Callback**. Under some condition, the callback will be called. The memory
   management of MoonBit requires the resource should be moved into the callback
   on its last call, but it is rather impossible to know which one is the last
   call, if the callback is multi-shot (i.e., can be called multiple times).
   Therefore, we simply send a shared reference into the callback every time.
3. **Finalization**. When a resource is closed, its reference in the event-loop
   is removed.

Or, this can be represented using `incref`/`decref` as:

1. **Initialization**: `incref(resource)`.
2. **Callback**: `incref(resource)`, then `cb->code(cb, resource)`.
3. **Finalization**: `decref(resource)`.

However, the rules above can be complicated by the calling convention of
MoonBit. MoonBit use a callee-saved ownership system, which means we should
`decref` all object before we exiting the function.

Here is an example of initialization of tcp stream:

```c
MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_tcp_init(uv_loop_t *loop, moonbit_uv_tcp_t *tcp) {
  // The event-loop holds a shared reference to the tcp stream, therefore we
  // need to incref here.
  moonbit_incref(tcp);
  // The tcp handle holds a shared reference to the event-loop at tcp->tcp.loop,
  // therefore we need to incref the loop here.
  moonbit_incref(loop);
  int result = uv_tcp_init(loop, &tcp->tcp);
  // We need to decref both the event-loop and the tcp stream, as required the
  // callee-saved calling convention.
  moonbit_decref(loop);
  moonbit_decref(tcp);
  return result;
}
```

As you may find out, the call to `moonbit_incref` and `moonbit_decref` can be
cancelled out, and forms a common pattern used in the binding C code:

```c
MOONBIT_FFI_EXPORT
int32_t
moonbit_uv_xxx_init(uv_loop_t *loop, moonbit_uv_xxx_t *xxx) {
  return uv_xxx_init(loop, &xxx->xxx);
}
```

For finalization, we use the `uv_close` from libuv as an example:

```c
static inline void
moonbit_uv_close_cb(uv_handle_t *handle) {
  moonbit_uv_close_cb_t *cb = handle->data;
  handle->data = NULL;
  // The handle is removed from event-loop, hence we decref it here.
  moonbit_decref(handle);
  // The callback is removed from handle, hence we decref it here.
  moonbit_decref(cb);
  // Incref all arguments before calling function to satisfy the callee-saved
  // calling convention.
  moonbit_incref(cb);
  moonbit_incref(handle);
  cb->code(cb, handle);
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_close(uv_handle_t *handle, moonbit_uv_close_cb_t *close_cb) {
  // We store an shared reference of `close_cb` into the `handle`, therefore we
  // need to incref it here.
  moonbit_incref(close_cb);
  // Because there is already a handle stored inside the event-loop, there is no
  // need to incref it here.
  moonbit_uv_handle_set_data(handle, close_cb);
  uv_close(handle, moonbit_uv_close_cb);
  moonbit_decref(handle);
  moonbit_decref(close_cb);
}
```

Cancel out all `incref`/`decref`, we can write the `uv_close` and `uv_close_cb`
as:

```c
static inline void
moonbit_uv_close_cb(uv_handle_t *handle) {
  moonbit_uv_close_cb_t *cb = handle->data;
  handle->data = NULL;
  cb->code(cb, handle);
}

MOONBIT_FFI_EXPORT
void
moonbit_uv_close(uv_handle_t *handle, moonbit_uv_close_cb_t *close_cb) {
  moonbit_uv_handle_set_data(handle, close_cb);
  uv_close(handle, moonbit_uv_close_cb);
  moonbit_decref(handle);
}
```

Technically this conforms to the callee-saved calling convention, but we choose
to put it explicitly here as the `decref` introduced by event-loop get cancelled
with an `incref` introduced by the calling convention.

Rest of the APIs should following the normal callee-saved calling convention to
`incref`/`decref` corresponding objects.
