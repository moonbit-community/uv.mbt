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

### Thread

- `uv_thread_create_ex()` - Extended thread creation with options

### Miscellaneous Utilities

- `uv_replace_allocator()` - Replace memory allocator
- `uv_library_shutdown()` - Shutdown library
- `uv_setup_args()` - Setup command line arguments
- `uv_get_process_title()` - Get process title
- `uv_set_process_title()` - Set process title
- `uv_resident_set_memory()` - Get RSS memory usage
- `uv_uptime()` - Get system uptime
- `uv_getrusage_thread()` - Get thread resource usage
- `uv_available_parallelism()` - Get available CPU parallelism
- `uv_loadavg()` - Get system load average

### Network Utilities

- `uv_inet_ntop()` - Convert network address to string
- `uv_inet_pton()` - Convert string to network address
- `uv_if_indextoname()` - Convert interface index to name
- `uv_if_indextoiid()` - Convert interface index to IID
