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
   ///|
   fn main {
     let uv = @uv.loop_alloc()
     @uv.loop_init(uv) |> ignore()
     fn on_exit(
       req : @uv.Process,
       exit_status : Int64,
       term_signal : Int
     ) -> Unit {
       println(
         "Process exited with status \{exit_status} and signal \{term_signal}",
       )
       @uv.process_close(req, fn(_) {
         @uv.stop(uv)
       })
     }

     let options = @uv.process_options_alloc()
     let args : FixedArray[Bytes?] = [
       Some(b"moon\x00"),
       Some(b"version\x00"),
       None,
     ]
     @uv.process_options_set_args(options, args)
     @uv.process_options_set_file(options, b"moon\x00")
     let child_req = @uv.process_alloc()
     let result = @uv.spawn(uv, child_req, options, on_exit)
     if result != 0 {
       println("Error spawning process: \{result}")
     } else {
       println("Launched process with ID \{@uv.process_get_pid(child_req)}")
     }
     @uv.run(uv, @uv.RunMode::Default) |> ignore()
     @uv.loop_close(uv) |> ignore()
   }
   ```
