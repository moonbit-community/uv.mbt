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

- `uv_loop_fork()` - Fork support for event loops
- `uv_backend_fd()` - Backend file descriptor access
- `uv_backend_timeout()` - Backend timeout information

### Handle Functions

- `uv_ref()` - Reference counting for handles
- `uv_unref()` - Unreference handles
- `uv_has_ref()` - Check handle reference status

### Stream Functions

- `uv_try_write()` - Non-blocking write attempt
- `uv_try_write2()` - Non-blocking write with handle passing

### TCP Functions

- `uv_tcp_init_ex()` - Extended TCP initialization

### Process Functions

- `uv_get_osfhandle()` - Get OS handle from file descriptor
- `uv_open_osfhandle()` - Open file descriptor from OS handle
