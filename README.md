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

### Miscellaneous Utilities

- `uv_replace_allocator()` - Replace memory allocator
- `uv_setup_args()` - Setup command line arguments
- `uv_get_process_title()` - Get process title
- `uv_set_process_title()` - Set process title
