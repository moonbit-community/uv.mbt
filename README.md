# tonyfettes/uv

This is a MoonBit binding to the [libuv](https://libuv.org) library.

## Quickstart

1. Add this module as a dependency to your MoonBit project.

   ```bash
   moon update
   moon add tonyfettes/uv
   ```

2. Import `tonyfettes/uv` package where you need it.

   ```json
   {
     "import": [
       "tonyfettes/uv"
     ]
   }
   ```

3. Use the `tonyfettes/uv` package in your MoonBit project.

   ```moonbit
   fn main {
     try {
       let uv = @uv.Loop::new()
       let options = @uv.ProcessOptions::new(
         "moon",
         ["moon", "version"],
         fn(process, exit_status, term_signal) {
           println(
             "Process exited with status \{exit_status} and signal \{term_signal}",
           )
           process.close(() => ())
         },
       )
       let process = uv.spawn(options)
       println("Launched process with ID \{(process).pid()}")
       uv.run(Default)
       uv.stop()
       uv.close()
     } catch {
       error => println("Error: \{error}")
     }
   }
   ```

## Roadmap

The following libuv APIs are not yet implemented in this library:

### Loop Functions

- `uv_default_loop()` - Access to the default event loop
- `uv_loop_configure()` - **Partially implemented**: Only supports `UV_LOOP_BLOCK_SIGNAL`, `UV_METRICS_IDLE_TIME`, and `UV_LOOP_USE_IO_URING_SQPOLL` options. Missing support for other loop configuration options.
- `uv_loop_fork()` - Fork support for event loops
- `uv_backend_fd()` - Backend file descriptor access
- `uv_backend_timeout()` - Backend timeout information

### Handle Functions

- `uv_ref()` - Reference counting for handles
- `uv_unref()` - Unreference handles
- `uv_has_ref()` - Check handle reference status
- `uv_send_buffer_size()` - Get/set send buffer size
- `uv_recv_buffer_size()` - Get/set receive buffer size

### Stream Functions

- `uv_stream_set_blocking()` - Set blocking mode for streams
- `uv_stream_get_write_queue_size()` - Get write queue size
- `uv_try_write()` - Non-blocking write attempt
- `uv_try_write2()` - Non-blocking write with handle passing

### TCP Functions

- `uv_tcp_init_ex()` - Extended TCP initialization
- `uv_tcp_keepalive_ex()` - Extended TCP keepalive configuration

### UDP Functions

- `uv_udp_init_ex()` - Extended UDP initialization
- `uv_udp_try_send2()` - Batch UDP send operations

### Process Functions

- `uv_setup_args()` - Setup process arguments
- `uv_get_osfhandle()` - Get OS handle from file descriptor
- `uv_open_osfhandle()` - Open file descriptor from OS handle

### System Information Functions

- `uv_get_passwd2()` - Get password entry by UID
- `uv_os_get_group()` - Get group information
- `uv_os_free_group()` - Free group information
- `uv_os_getpriority()` - Get process priority
- `uv_os_setpriority()` - Set process priority
- `uv_cpumask_size()` - Get CPU mask size

### Thread Functions

- `uv_thread_create_ex()` - Extended thread creation with options

### Threading Utilities

- `uv_replace_allocator()` - Replace memory allocator

### Debug Functions

- `uv_print_all_handles()` - **Partially implemented**: Available through `Loop::print_all_handles()`, but only supports printing to file descriptors (takes a `File` parameter). Missing the more general `FILE*` stream support.
- `uv_print_active_handles()` - Debug function to print active handles (completely missing)

### Unicode Functions

- `uv_utf16_length_as_wtf8()` - Unicode conversion utilities
- `uv_utf16_to_wtf8()` - Unicode conversion utilities
- `uv_wtf8_length_as_utf16()` - Unicode conversion utilities
- `uv_wtf8_to_utf16()` - Unicode conversion utilities

### Notes on Partial Implementations

Several functions marked as "partially implemented" are actually fully functional for most use cases, but the MoonBit bindings provide higher-level abstractions that hide some of the lower-level C API details:

- **Thread affinity functions**: The MoonBit API uses a `CpuSet` type and manages memory automatically, whereas the C API requires manual buffer management.
- **Interface name/ID functions**: Automatic buffer resizing and memory management in MoonBit vs. manual buffer size handling in C.
- **Print functions**: Simplified to work with MoonBit's `File` type rather than C `FILE*` pointers.

These abstractions make the API more ergonomic for MoonBit users while maintaining the core functionality of the underlying libuv operations.

This roadmap represents the gap between the comprehensive libuv C API and the current MoonBit binding implementation. Contributions implementing any of these APIs are welcome!
